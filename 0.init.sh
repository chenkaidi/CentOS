#!/bin/bash

timedatectl set-timezone Asia/Shanghai

#service iptables stop   #centos6
#chkconfig iptables off   #centos6
systemctl stop firewalld   #centos7
systemctl disable firewalld #centos7
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

echo "
* soft nofile 655350
* hard nofile 655350
* soft nproc 655350
* soft nproc 655350
" >> /etc/security/limits.conf
echo "*          soft    nproc     655350" >> /etc/security/limits.d/20-nproc.conf
ulimit -n 655350
ulimit -u 655350

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
