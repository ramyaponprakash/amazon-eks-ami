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
# CIS Amazon Linux 2 and GCC CTS Amazon Linux 2)
# "3.1.1 - ensure IP forwarding is disabled"
# Our current AMI will skip the CIS guide
# details) # https://repost.aws/knowledge-center/eks-pod-connections
enabled_ip_forward() {
  echo "3.1.1 - ensure IP forwarding is disabled - exception"
  sed -i -e "s#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g" /etc/sysctl.conf # required to allow pod to pod, pod to external
  sysctl -w net.ipv4.ip_forward=1
}

# GCC CTS compatibility due to sysctl error
restrict_core_dump() {
  echo "1.5.1 - ensure core dumps are restricted - moving it to /etc/security/limits.d"
  sed -i -e "s#* hard core 0##g" /etc/sysctl.conf
  echo "* hard core 0" > /etc/security/limits.d/cis.conf
  echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/cis.conf
}

apply_sysctl_settings() {
  enabled_ip_forward
  restrict_core_dump
  # NOTE: sysctl SYSTEM FILE PRECEDENCE
  #  /etc/sysctl.d/*.conf
  #  /run/sysctl.d/*.conf
  #  /usr/local/lib/sysctl.d/*.conf
  #  /usr/lib/sysctl.d/*.conf
  #  /lib/sysctl.d/*.conf
  #  /etc/sysctl.conf
  #
  # NOTE: sysctl -e --system (or sysctl -p is not working well in GCC CTS, refer 'enable_last_run_service')
  sysctl -e --system && sysctl --all
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

# ===== GCC CTS support =====
# TODO:
# 1) remove the service if it is ok to be removed.
#   > The sysctl is not overwriting the config via 'sysctl --system' and it is not persist.
#   > So until find the root reason, the last-run service will run commands for init and reboots.
#
enable_last_run_service() {
  cat << EOF > /etc/eks/last-run.sh
#!/bin/bash
echo "Overwriting ipv4.ip_forward for CTS image"
sysctl -w net.ipv4.ip_forward=1
EOF
  chmod +x /etc/eks/last-run.sh

  cat << EOF > /etc/eks/last-run.service
[Unit]
Description=Last run service to overwrite config or others on reboot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/etc/eks/last-run.sh

[Install]
WantedBy=multi-user.target
EOF
  cp -v /etc/eks/last-run.service /etc/systemd/system/last-run.service
  chown root:root /etc/systemd/system/last-run.service
  systemctl daemon-reload
  systemctl enable last-run
}


# ===== main =====
setup_essential_iptables_rules
setup_iptables_restore
apply_sysctl_settings
set_kubelet_config
enable_last_run_service
reboot