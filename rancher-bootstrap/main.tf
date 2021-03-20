terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.0.3"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.12.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = var.api_url
  insecure  = true
  bootstrap = true
  retries   = 60
}

provider "rancher2" {
  insecure  = true
  api_url   = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  values           = [file("rancher_values.yaml")]
  depends_on       = [helm_release.cert-manager]
}

resource "rancher2_bootstrap" "admin" {
  provider   = rancher2.bootstrap
  password   = var.admin_password
  telemetry  = var.telemetry
  depends_on = [helm_release.rancher]
}

resource "rancher2_user" "new_admin" {
  username = var.new_admin_user
  password = var.new_admin_password
  enabled  = true
}

resource "rancher2_global_role_binding" "new_admin" {
  global_role_id = "admin"
  user_id        = rancher2_user.new_admin.id
}

resource "null_resource" "gitrepo-rancher" {
  provisioner "local-exec" {
    command = "kubectl apply -f gitrepo-rancher.yaml"
  }
  depends_on = [rancher2_bootstrap.admin]
}
