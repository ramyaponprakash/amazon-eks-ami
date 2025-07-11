firewall-cmd --permanent --zone=public --set-target=ACCEPT
firewall-cmd --permanent --zone=public --set-target=ACCEPT
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=4120/tcp
firewall-cmd --permanent --zone=public --add-port=4122/tcp
firewall-cmd --permanent --zone=public --add-port=3128/tcp
firewall-cmd --permanent --zone=trusted --add-interface=lo
firewall-cmd --permanent --zone=trusted --remove-source=127.0.0.0/8
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="127.0.0.0/8" drop'
firewall-cmd --permanent --zone=public --add-rich-rule='rule protocol value="tcp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule protocol value="udp" accept'
firewall-cmd --permanent --zone=public --add-icmp-block-inversion=no
firewall-cmd --permanent --zone=public --add-icmp-block=no
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --add-port=68/udp
firewall-cmd --permanent --zone=public --add-port=123/udp
firewall-cmd --permanent --zone=public --add-port=323/udp
firewall-cmd --permanent --zone=trusted --add-interface=lo
firewall-cmd --permanent --zone=public --add-rich-rule='rule protocol value="tcp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule protocol value="udp" accept'
firewall-cmd --permanent --zone=public --add-icmp-block=no
firewall-cmd --reload
firewall-cmd --list-all --zone=public
sudo systemctl enable firewalld
sudo systemctl start firewalld