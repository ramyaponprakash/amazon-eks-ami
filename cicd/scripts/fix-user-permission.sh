#!/bin/bash

EC2_USER=$1

chown root:root /home
chmod 755 /home
chown $EC2_USER:$EC2_USER /home/$EC2_USER -R
chmod 700 /home/$EC2_USER /home/$EC2_USER/.ssh
chmod 600 /home/$EC2_USER/.ssh/authorized_keys
