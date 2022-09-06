#!/bin/bash

timedatectl set-timezone Asia/Shanghai

systemctl stop firewalld   #centos7
systemctl disable firewalld #centos7

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

echo "
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* soft nproc 65535
" >> /etc/security/limits.conf
echo "*          soft    nproc     65535" >> /etc/security/limits.d/20-nproc.conf
ulimit -n 65535
ulimit -u 65535

echo "
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 4096 65000
net.core.netdev_max_backlog =  10240
net.core.somaxconn = 1024
vm.overcommit_memory = 1
vm.max_map_count = 262144
" >> /etc/sysctl.conf
sysctl -p

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local


# ulimit不生效时, 处理方法：

cat > /etc/pam.d/sshd <<EOF
#%PAM-1.0
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
EOF

sed -i 's/#UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config

echo "DefaultLimitNOFILE=65535" >>/etc/systemd/system.conf
systemctl daemon-reexec

systemctl restart sshd
