#!/bin/bash
clear

#read -p "Enter your Docker username: " username
interface=$(ip route | grep default | awk '{print $5}')
resolvectl dns $interface 178.22.122.100 185.51.200.2
echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf
docker login
