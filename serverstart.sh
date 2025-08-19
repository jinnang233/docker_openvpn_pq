#!/usr/bin/env bash
iptables -A FORWARD -i tun0 -o eth0 -s 10.192.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -s 10.192.0.0/24 -j MASQUERADE
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
openvpn --config /etc/openvpn/server.conf

