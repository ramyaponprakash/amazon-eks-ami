#!/usr/bin/bash

set -o pipefail
set -o nounset
set -o errexit

echo "post provisioning script is running ..."

ensure_iptables_rule() {
  if ! iptables-save | grep -q "$1"; then
    sudo $1
    sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null
    echo "New iptables rule($1) added successfully."
  else
    echo "The iptables rule($1) already exists."
  fi
}

# ===== K8 networking =====
setup_essential_iptables_rules() {
  echo "Allow 10250 for kubelet API server (so kubectl logs/exec works)"
  ensure_iptables_rule "iptables -I INPUT -p tcp -m tcp --dport 10250 -j ACCEPT"
}

setup_iptables_restore() {
  echo "Enabling iptables-restore"
  cat << EOF > /etc/eks/iptables-restore.service
[Unit]
Description=Restore iptables

[Service]
Type=oneshot
ExecStart=/bin/bash -c "/sbin/iptables-restore < /etc/sysconfig/iptables"

[Install]
WantedBy=multi-user.target
EOF
  sudo cp -v /etc/eks/iptables-restore.service /etc/systemd/system/iptables-restore.service
  sudo chown root:root /etc/systemd/system/iptables-restore.service
  sudo systemctl daemon-reload
  sudo systemctl enable iptables-restore
}

# ===== Pod to pod communication issues =====
# CIS Amazon Linux 2) "3.1.1 - ensure IP forwarding is disabled"
# sysctl_entry "net.ipv4.ip_forward = 0"
# sysctl_entry "net.ipv6.conf.all.forwarding = 0"
#
# Our current AMI will skip the CIS guide
# details) # https://repost.aws/knowledge-center/eks-pod-connections
enabled_ip_forward() {
  echo "3.1.1 - ensure IP forwarding is disabled - exception"
  sudo sed -i -e "s#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g" /etc/sysctl.conf # required to allow pod to pod, pod to external
  #echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf # required to allow to adopt CNI plug-in
  #sudo modprobe br_netfilter
  sudo sysctl -p
}


# ===== main =====
setup_essential_iptables_rules
setup_iptables_restore
enabled_ip_forward
sudo reboot