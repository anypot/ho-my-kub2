#!/bin/bash

usage () {
  cat << EOF
Usage: $(basename $0)
-h, --help                                     Print this help
-c, --helm-charts < all | chart1,chart2,... >  Install Helm charts
-i, --infra < name >                           Apply Terraform plan with <name>.tfvars in workspace <name>
EOF
}

charts_install () {
  local to_install=""
  local chart_list_all=$(find ${CHARTSDIR}/* -maxdepth 1 -type d -exec basename {} \;)
  
  [[ ${CHARTS} == "all" ]] && to_install=${chart_list_all} || to_install=${CHARTS//,/ }
  
  for chart in ${to_install}; do
    [[ ! -d ${CHARTSDIR}/${chart} ]] && echo "${chart} does not exist, skipping..." && continue
    helm repo add $(cat ${CHARTSDIR}/${chart}/chart_repo)
  done
  helm repo update

  local repo_name=""
  local release=""
  local namespace=""
  for chart in ${to_install}; do
    [[ ! -d ${CHARTSDIR}/${chart} ]] && echo "${chart} does not exist, skipping..." && continue
    release=${chart}
    repo_name=$(cat ${CHARTSDIR}/${chart}/chart_repo | cut -d " " -f1)
    [[ -f ${CHARTSDIR}/${chart}/namespace ]] && namespace=$(cat ${CHARTSDIR}/${chart}/namespace) || namespace=${chart}
    kubectl create ns ${namespace}
    helm upgrade ${release} ${repo_name}/${chart} -i -f ${CHARTSDIR}/${chart}/values.yaml -n ${namespace}
  done
}

infra_deploy () {
  [[ ! -f ${INFRADIR}/${INFRA}.tfvars ]] && echo "${INFRADIR}/${INFRA}.tfvars does not exist !" && exit 1
  [[ -f ${INFRADIR}/terraform.tfvars ]] && rm ${INFRADIR}/terraform.tfvars
  ln -s ${INFRADIR}/${INFRA}.tfvars ${INFRADIR}/terraform.tfvars
  cd ${INFRADIR}
  terraform init
  terraform workspace list | grep -sw ${INFRA}
  [[ $? == 1 ]] && terraform workspace new ${INFRA}
  terraform workspace select ${INFRA}
  terraform plan
  terraform apply
}


PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -i|--infra)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        INFRA=$2
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
	usage
	exit 1
      fi
      ;;
    -c|--helm-charts)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CHARTS=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
	usage
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      usage
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"


BASEDIR=$(dirname $(readlink -f $0))
INFRADIR=${BASEDIR}/plan
CHARTSDIR=${BASEDIR}/charts

[[ ! -z ${INFRA+x} ]] && infra_deploy
[[ ! -z ${CHARTS+x} ]] && charts_install
