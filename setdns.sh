#!/bin/bash
clear

interface=$(ip route | grep default | awk '{print $5}')
resolvectl dns $interface 178.22.122.100 185.51.200.2
cp /etc/resolv.conf /etc/resolv.conf.backup
echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf
docker login
resolvectl dns $interface 8.8.8.8 8.8.4.4
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
