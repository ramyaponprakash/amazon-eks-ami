#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

# upgrade the operating system. add additional packages below
yum update -y && yum autoremove -y && \
  yum install -y unzip


# ===== kube-proxy iptables issue ====
# Select "iptables-legacy" as the default option (due to kube-proxy limitation for now)
# https://github.com/kubernetes/kubernetes/issues/112477
# https://github.com/kubernetes/enhancements/pull/3824 (enhancement pending)
default_iptables_legacy() {
  iptables-save | tee /etc/sysconfig/iptables > /dev/null
  echo "Selecting iptables-legacy as the default."
  update-alternatives --set iptables /usr/sbin/iptables-legacy
  echo "Restoring CIS hardened iptables rules"
  bash -c "iptables-restore < /etc/sysconfig/iptables"
}

# pipeline compatibility
ensure_install_awscli_v2() {
  echo "Uninstalling awscli v1"
  yum remove -y awscli

  # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  echo "Installing awscli v2 bundle"

  MACHINE=$(uname -m)
  if [ "$MACHINE" == "x86_64" ]; then
    ARCH="amd64"
  elif [ "$MACHINE" == "aarch64" ]; then
    ARCH="arm64"
  else
    echo "Unknown machine architecture '$MACHINE'" >&2
    exit 1
  fi

  AWSCLI_DIR="/home/ec2-user/awscli-install"
  mkdir "${AWSCLI_DIR}"
  curl \
    --silent \
    --show-error \
    --retry 10 \
    --retry-delay 1 \
    -L "https://awscli.amazonaws.com/awscli-exe-linux-${MACHINE}.zip" -o "${AWSCLI_DIR}/awscliv2.zip"
  unzip -q "${AWSCLI_DIR}/awscliv2.zip" -d ${AWSCLI_DIR}
  "${AWSCLI_DIR}/aws/install" --bin-dir /bin/ --update
  chmod -R 755 /usr/local/aws-cli/
  aws --version
}

# ===== main =====
default_iptables_legacy
ensure_install_awscli_v2
reboot