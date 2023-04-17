MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Create the containerd and sandbox-image systemd directory
mkdir -p /etc/systemd/system/containerd.service.d
mkdir -p /etc/systemd/system/sandbox-image.service.d

# Configure yum to use the proxy
cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
proxy=${HTTP_PROXY}
EOF

#Set the proxy for future processes, and use as an include file
cloud-init-per instance proxy_config cat << EOF >> /etc/environment
http_proxy=${HTTP_PROXY}
https_proxy=${HTTP_PROXY}
HTTP_PROXY=${HTTP_PROXY}
HTTPS_PROXY=${HTTP_PROXY}
no_proxy=${NO_PROXY_HOST}
NO_PROXY=${NO_PROXY_HOST}
EOF

#Configure Containerd with the proxy
cloud-init-per instance containerd_proxy_config tee <<EOF /etc/systemd/system/containerd.service.d/http-proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Configure sandbox-image with the proxy
cloud-init-per instance sandbox-image_proxy_config tee <<EOF /etc/systemd/system/sandbox-image.service.d/http-proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Configure the kubelet with the proxy
cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

cloud-init-per instance reload_daemon systemctl daemon-reload

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex

set -a
source /etc/environment

yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent

/etc/eks/bootstrap.sh ${CLUSTER_NAME} \
  --apiserver-endpoint ${API_SERVER_URL} \
  --b64-cluster-ca ${B64_CLUSTER_CA} \
  --container-runtime containerd \
  --dns-cluster-ip 10.100.0.10 \
  --use-max-pods false \
  --kubelet-extra-args '--max-pods=${MAX_POD}'

--==MYBOUNDARY==--