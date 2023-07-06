#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

echo "post provisioning script is running ..."

ensure_iptables_rule() {
  if ! iptables-save | grep -q "$1"; then
    $2
    iptables-save | tee /etc/sysconfig/iptables > /dev/null
    echo "New iptables rule($2) added successfully."
  else
    echo "The iptables rule($2) already exists."
  fi
}

# ===== K8 networking =====
setup_essential_iptables_rules() {
  echo "Allow 10250 for kubelet API server (so kubectl logs/exec works)"
  ensure_iptables_rule "10250 -j ACCEPT" "iptables -I INPUT 1 -p tcp -m tcp --dport 10250 -j ACCEPT"
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
  cp -v /etc/eks/iptables-restore.service /etc/systemd/system/iptables-restore.service
  chown root:root /etc/systemd/system/iptables-restore.service
  systemctl daemon-reload
  systemctl enable iptables-restore
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
  sed -i -e "s#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g" /etc/sysctl.conf # required to allow pod to pod, pod to external
  if [ -f "/etc/sysctl.d/cis.conf" ]; then
      sed -i -e "s#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g" /etc/sysctl.d/cis.conf
  fi
  #echo "net.bridge.bridge-nf-call-iptables = 1" | tee -a /etc/sysctl.conf # required to allow to adopt CNI plug-in
  #modprobe br_netfilter
  sysctl -p
}

# ===== kubelet =====
# EKS CIS 3.2.9 Ensure that the --eventRecordQPS argument is set to 0 or a level which ensures appropriate event capture (Automated)
#
# Impact: Setting this parameter to 0 could result in a denial of service condition due to excessive events being created.
# The cluster's event processing and storage systems should be scaled to handle expected event loads.
# https://www.tenable.com/audits/items/CIS_Kubernetes_v1.5.1_Level_2.audit:45d7b4a3eec0a197a3441e495b02a58a
#
# Note: We set 5 following audit guide. From k8 1.27, it is default 50.
set_kubelet_config() {
  echo "Updating kubelet config"

  echo "CIS 3.2.9 Ensure that the --eventRecordQPS argument is set to 0 or a level which ensures appropriate event capture"
  echo "$(jq ".eventRecordQPS=5" /etc/kubernetes/kubelet/kubelet-config.json)" > /etc/kubernetes/kubelet/kubelet-config.json

  systemctl daemon-reload
  if [[ "$(systemctl is-active kubelet)" == "active" ]]; then
    systemctl restart kubelet
  fi
}


# ===== main =====
setup_essential_iptables_rules
setup_iptables_restore
enabled_ip_forward
set_kubelet_config
reboot