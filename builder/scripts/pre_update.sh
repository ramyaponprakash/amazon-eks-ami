#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

# upgrade the operating system. add additional packages below
yum update -y && yum autoremove -y


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

# ===== main =====
default_iptables_legacy
reboot