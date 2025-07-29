# --- Ensure legacy iptables is used ---
dnf install -y iptables iptables-legacy

# Switch to legacy iptables alternatives
alternatives --set iptables /usr/sbin/iptables-legacy
alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Stop and disable nftables
systemctl stop nftables
systemctl disable nftables

# Restore saved iptables rules if any
if [ -f /etc/sysconfig/iptables ]; then
    iptables-restore < /etc/sysconfig/iptables
fi


#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

# upgrade the operating system. add additional packages below
dnf update -y && dnf autoremove -y && \
  dnf install -y unzip


remove_unused_packages() {
    # TODO: remove below
    echo "remove_unused_packages - removing ds_agent, splunkforwarder temporally"
    dnf remove -y ds_agent
    dnf remove -y splunkforwarder

    # NOTE: we remove ssm-agent of CTS image here and let amazon-eks-ami install it again
    #       dnf exit 1 when package is already installed
    dnf remove -y amazon-ssm-agent

    dnf autoremove -y && dnf clean all
}

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
  dnf remove -y awscli

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
remove_unused_packages
default_iptables_legacy
ensure_install_awscli_v2
reboot