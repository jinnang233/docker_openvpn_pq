#!/bin/bash
set -e

mkdir -p /etc/openvpn

cd /etc/openvpn/

mkdir ccd
touch ipp.txt
touch openvpn-status.log

openvpn --genkey --secret ta.key
openssl genpkey -algorithm ML-DSA-87 -out ca.key
openssl req -new -x509 -nodes -key ca.key -out ca.crt -subj "/CN=MyVPN-CA" -days 3650


openssl genpkey -algorithm ML-DSA-87 -out server.key
openssl req -new -key server.key -out server.csr -subj "/CN=MyVPN-Server"


openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -extensions server -extfile /server.ext

echo "generated: ca.key, ca.crt, server.key, server.crt"

