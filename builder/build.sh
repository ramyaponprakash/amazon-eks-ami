#!/bin/bash

set -o pipefail
set -o errexit

usage () {
  echo '============================================'
  echo 'CIS Amazon Linux 2 EKS optimised AMI builder'
  echo '============================================'
  echo 'Please run this within the host that able to access the ES via security group settings'
  echo '-c : cluster name'
  echo '-k : k8 version'
  echo '-v : vpc id'
  echo '-s : subnet id'
  echo '-i : CIDR for temporal ECS instance security group ssh access'
  echo '-p : Allowing to run packer in public host (Dev)'
}

parse_inputs() {
  local opt OPTIND
  while getopts 'c:k:v:s:i:p:-:' opt; do
    case $opt in
        c) CLUSTER_NAME=$OPTARG;;
        k) K8_VERSION=$OPTARG;;
        v) VPC_ID=$OPTARG;;
        s) SUBNET_ID=$OPTARG;;
        i) EXEC_CIDR=$OPTARG;;
        p) PUBLIC_ACCESS=$OPTARG;;
        -)
          case "${OPTARG}" in
            *) usage; exit 1;;
          esac;;
        *) usage; exit 1;;
    esac
  done
  shift $((OPTIND -1))
}

setup_aws_vars() {
  ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
  AWS_REGION="ap-southeast-1"
  if [ -z "$VPC_ID" ] || [ -z "$SUBNET_ID" ]; then
    echo "AMI builder VPC_ID or SUBNET_ID not provided, will use EKS cluster's setup"
    VPC_ID=$(aws eks describe-cluster --name "$CLUSTER_NAME" --output text --query 'cluster.resourcesVpcConfig.vpcId')
    SUBNET_ID=$(aws eks describe-cluster --name "$CLUSTER_NAME" --output text --query 'cluster.resourcesVpcConfig.subnetIds[0]')
  fi
  echo "VPC_ID=$VPC_ID"
  echo "SUBNET_ID=$SUBNET_ID"
  echo "AWS_REGION=$AWS_REGION"
}

get_latest_ami_vars() {
  AMI_OWNER_ACCOUNT_ID="679593333241"
  AMI_FILTER="CIS Amazon Linux 2 Kernel 5.10 Benchmark"
  AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=$AMI_FILTER*" --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
  AMI_NAME=$(aws ec2 describe-images --filters "Name=name,Values=$AMI_FILTER*" --query 'sort_by(Images, &CreationDate)[-1].Name' --output text)
  echo "AMI_ID=$AMI_ID"
  echo "AMI_NAME=$AMI_NAME"
  echo "AMI_OWNER_ACCOUNT_ID=$AMI_OWNER_ACCOUNT_ID"
}

install_packer() {
  if [ "$PLATFORM" == "Darwin" ]; then
    curl -O https://releases.hashicorp.com/packer/$1/packer_$1_darwin_amd64.zip
    unzip packer_$1_darwin_amd64.zip && rm packer_$1_darwin_amd64.zip
  elif [ "$PLATFORM" == "Linux" ]; then
    wget https://releases.hashicorp.com/packer/$1/packer_$1_linux_amd64.zip
    unzip packer_$1_linux_amd64.zip && rm packer_$1_linux_amd64.zip
  else
    echo "$PLATFORM does not support" && exit 1
  fi
}

install_deps() {
  PLATFORM=$(uname)
  PACKER_VERSION="1.9.1"
  PACKER_BINARY="./packer" # Bamboo compatibility
  if ! command -v $PACKER_BINARY &> /dev/null; then
    echo "packer not installed, installing ..."
    install_packer $PACKER_VERSION
  fi

  # Bamboo compatibility
  REQUIRED_PACKER_VERSION="v1.8.0"
  INSTALLED_PACKER_VERSION=$($PACKER_BINARY version | awk '{print $2}')
  if [[ $(printf '%s\n' "$REQUIRED_PACKER_VERSION" "$INSTALLED_PACKER_VERSION" | sort -rV | head -n1) != "$REQUIRED_PACKER_VERSION" ]]; then
      echo "Packer version $INSTALLED_PACKER_VERSION is above $REQUIRED_PACKER_VERSION"
  else
      echo "Packer version $INSTALLED_PACKER_VERSION is not above $REQUIRED_PACKER_VERSION, installing packer v$PACKER_VERSION"
      install_packer $PACKER_VERSION
  fi
}

clean_repo() {
  cd $1
  git reset --hard
  cd ..
}

ensure_repo() {
  git submodule update --remote
  clean_repo $1
}

modify_repo_scripts_cis_compatibility() {
  sed -i -e "s#/tmp#$1#g" $2/eks-worker-al2.json
  sed -i -e "s#/tmp#$1#g" $2/scripts/cleanup.sh
  sed -i -e "s#/tmp#$1#g" $2/scripts/generate-version-info.sh
  sed -i -e "s#/tmp#$1#g" $2/scripts/install-worker.sh
  sed -i -e "s#/tmp#$1#g" $2/log-collector-script/linux/eks-log-collector.sh
  sed -i -e "s#/tmp#$1#g" $2/files/bootstrap.sh
  sed -i -e "s#/tmp#$1#g" $2/files/bin/imds

  sed -i -e 's#chmod +x#chmod 755#g' $2/eks-worker-al2.json
  sed -i -e 's#sudo chmod +x $binary#sudo chmod 755 $binary#g' $2/scripts/install-worker.sh
  sed -i -e 's#aws --version#sudo /bin/aws --version#g' $2/scripts/generate-version-info.sh

  # https://github.com/hashicorp/packer/issues/10011
  echo "Adding CIS compatibility to packer conf file"
  jq '(.provisioners[] | select(.type == "shell" and (.execute_command | not))) |= . + {"execute_command": "{{ .Vars }} bash '\''{{ .Path }}'\''"}' $2/eks-worker-al2.json > $2/temp.json && mv $2/temp.json $2/eks-worker-al2.json
}

add_pre_provisioning_scripts() {
  echo "Adding pre scripts to packer conf file"
  jq '.provisioners = [{
      "type": "shell",
      "remote_folder": "{{ user `remote_folder`}}",
      "expect_disconnect": true,
      "pause_after": "90s",
      "scripts": [
        "{{template_dir}}/scripts/pre_update.sh"
      ],
      "execute_command": "{{ .Vars }} sudo bash '\''{{ .Path }}'\''"
  }] + .provisioners' $1/eks-worker-al2.json > $1/temp.json && mv $1/temp.json $1/eks-worker-al2.json
}

add_post_provisioning_scripts() {
  echo "Adding post scripts to packer conf file"
  jq '.provisioners += [{
      "type": "shell",
      "remote_folder": "{{ user `remote_folder`}}",
      "expect_disconnect": true,
      "pause_before": "60s",
      "pause_after": "30s",
      "scripts": [
        "{{template_dir}}/scripts/post_harden.sh"
      ],
      "execute_command": "{{ .Vars }} sudo bash '\''{{ .Path }}'\''"
  }]' $1/eks-worker-al2.json > $1/temp.json && mv $1/temp.json $1/eks-worker-al2.json
}

main() {
  REMOTE_FOLDER="/home/ec2-user"
  REPO_FOLDER="./amazon-eks-ami"

  parse_inputs "$@"
  setup_aws_vars
  get_latest_ami_vars
  install_deps
  ensure_repo $REPO_FOLDER

  echo "Processing scripts and configs ..."
  cp -r ./scripts/ $REPO_FOLDER/scripts/
  modify_repo_scripts_cis_compatibility $REMOTE_FOLDER $REPO_FOLDER
  add_pre_provisioning_scripts $REPO_FOLDER
  add_post_provisioning_scripts $REPO_FOLDER
  AMI_NAME_PREFIX="adex-sol-eks-node-$K8_VERSION-v$(date +'%Y%m%d')-$(uuidgen)"

  echo "baking AMI .... K8_VERSION=$K8_VERSION"
  make -C $REPO_FOLDER "$K8_VERSION" \
    PACKER_BINARY="../packer" \
    aws_region="$AWS_REGION" \
    source_ami_id="$AMI_ID" \
    source_ami_owners="$AMI_OWNER_ACCOUNT_ID" \
    source_ami_filter_name="$AMI_NAME" \
    ami_name="$AMI_NAME_PREFIX" \
    subnet_id="$SUBNET_ID" \
    volume_type="gp3" \
    launch_block_device_mappings_volume_size="20" \
    temporary_security_group_source_cidrs="$EXEC_CIDR" \
    associate_public_ip_address="$PUBLIC_ACCESS" \
    remote_folder="$REMOTE_FOLDER"
  echo "baking AMI .... DONE!"

  echo "version-info.json"
  jq . "$REPO_FOLDER/$AMI_NAME_PREFIX-version-info.json"

  clean_repo $REPO_FOLDER
}

main "$@"
