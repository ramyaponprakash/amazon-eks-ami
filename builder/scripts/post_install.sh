#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

echo "post installing script is running ..."

configure_ds_agent() {
  echo "TODO: configure_ds_agent"
  # TODO: review ds_agent installation, define scope of scan(conf) and resources(cgroups)
}

configure_splunk() {
  echo "TODO: configure_splunk"
  # TODO: review splunkforwarder installation, define resources(cgroups)
}

configure_aide() {
  # EKS runs applications within containers. Each container is ephemeral and can be replaced or restarted at any time.
  # AIDE may face challenges in maintaining accurate file integrity checks within a dynamic and containerized environment.
  # Running AIDE on an EKS cluster can potentially consume significant system resources.
  # This can impact the performance and stability of your EKS cluster.
  # If we need AIDE, need to limit the scope using config file and need cgroups to limit cpu usage.
  rm -f /etc/cron.d/aide
  yum remove -y aide
}

# ===== main =====
configure_ds_agent
configure_splunk
configure_aide
yum autoremove -y && yum clean all