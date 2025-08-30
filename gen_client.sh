#!/bin/bash

folder_num=${RANDOM}
mkdir -p /etc/openvpn/clients/${folder_num}
cd /etc/openvpn/clients/${folder_num}

openssl genpkey -algorithm ML-DSA-87 -out /etc/openvpn/clients/${folder_num}/client.key
openssl req -new -key /etc/openvpn/clients/${folder_num}/client.key -out /etc/openvpn/clients/${folder_num}/client.csr -subj "/CN=MyVPN-Client-${folder_num}"
openssl x509 -req -in client.csr -CA /etc/openvpn/ca.crt -CAkey /etc/openvpn/ca.key -CAcreateserial -out /etc/openvpn/clients/${folder_num}/client.crt -extensions client -extfile /client.ext

cp /etc/openvpn/ca.crt /etc/openvpn/clients/${folder_num}/ca.crt
cp /etc/openvpn/ta.key /etc/openvpn/clients/${folder_num}/ta.key

touch /etc/openvpn/ccd/MyVPN-Client-${folder_num}

echo "generated in ${folder_num}: client.key, client.crt"
