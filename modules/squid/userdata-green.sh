#!/bin/bash

setup_proxy() {
  # Skip update_env_vars task if http_proxy is "empty"
  if [ "${http_proxy}" == "" ]; then
    echo "Skipping update_env_vars task because http_proxy is empty"
    return
  fi

   # Write the environment variables to the temporary file
  cat <<EOF > /etc/environment
http_proxy=${http_proxy}
https_proxy=${https_proxy}
no_proxy=${no_proxy}
EOF
  chmod 644 /etc/environment

  if [ "$PKG" == "apt" ]; then
    cat << EOF > /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "${http_proxy}";
Acquire::https::Proxy "${https_proxy}";
EOF
  elif [ "$PKG" == "yum" ]; then
    cat << EOL >> /etc/yum.conf
proxy=${https_proxy}
proxy_username=
proxy_password=
EOL
  fi
}

yum_update() {
    yum update -y
    curl -s https://adex-lib-mirror.s3.ap-southeast-1.amazonaws.com/aws/awscliv2.tgz -o ~/awscliv2.tgz
    tar -xzf ~/awscliv2.tgz && ./aws/install && rm -rf ~/aws/ ~/awscliv2.tgz
}
yum_update

mountcis() {
    echo "tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid,seclabel 0 0" >> /etc/fstab
    echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    echo "/dev/nvme1n1p1 /var/log ext4 defaults,nofail 0 2" >> /etc/fstab
    echo "/dev/nvme1n1p2 /var/tmp ext4 defaults,nofail 0 2" >> /etc/fstab
}
mountcis

install_squid() {
    mkdir -p /home/ec2-user/tmp/
    aws s3 cp s3://sdx-squid/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm /home/ec2-user/tmp/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm --no-progress
    rpm -Uvh /home/ec2-user/tmp/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm
    aws s3 cp s3://sdx-squid/squid-6.0.3-1.el8.x86_64.rpm /home/ec2-user/tmp/squid-6.0.3-1.el8.x86_64.rpm --no-progress
    rpm -Uvh /home/ec2-user/tmp/squid-6.0.3-1.el8.x86_64.rpm
    aws s3 cp s3://sdx-squid/config/grp-squid-mod-fwd.sh /home/ec2-user/tmp/grp-squid-mod-fwd.sh --no-progress
    /bin/bash -x /home/ec2-user/tmp/grp-squid-mod-fwd.sh 2>&1 >> /home/ec2-user/tmp/grp-squid-mod-fwd.log
    aws s3 cp s3://sdx-squid/config/config-solx/squid.conf /etc/squid/squid.conf --no-progress
    systemctl enable squid
    systemctl restart squid
    (crontab -l; echo '0 0 * * * /sbin/squid -k rotate') | crontab -
    echo "proxy=http://127.0.0.1:3128" >> /etc/yum.conf
    export http_proxy=http://127.0.0.1:3128
    export https_proxy=http://127.0.0.1:3128
}
install_squid

stop_cts_services() {
    if [ -d /opt/splunkforwarder ]; then (systemctl stop splunk && systemctl disable splunk); fi
    if [ -d /opt/nessus_agent ]; then (systemctl stop nessusagent && systemctl disable nessusagent); fi
}
stop_cts_services


cleanup_history() {
    if [ -f /usr/lib/systemd/system/rsyslog.service ]; then (systemctl stop rsyslog && systemctl disable rsyslog); fi
    grep -q 'history -cw' /etc/bash.bash_logout || echo "history -cw && rm -f ~/.bash_history" >> /etc/bash.bash_logout && chmod 644 /etc/bash.bash_logout
    grep -q 'history -cw' /root/.bashrc || echo "history -cw && rm -f ~/.bash_history" >> /root/.bashrc && chmod 644 /root/.bashrc
}
cleanup_history
