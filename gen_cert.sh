#!/usr/bin/env bash

set -euo pipefail

OPENVPN_DIR="${OPENVPN_DIR:-/etc/openvpn}"
SERVER_EXT_TEMPLATE="${SERVER_EXT_TEMPLATE:-/server.ext}"
SERVER_CONF_TEMPLATE="${SERVER_CONF_TEMPLATE:-/server.conf}"
SERVER_EXT="${OPENVPN_DIR}/server.ext"

: "${ENV_SERVER_IP:?Set ENV_SERVER_IP to the server IP address used in the certificate SAN.}"
: "${ENV_SERVER_DNS:?Set ENV_SERVER_DNS to the server DNS name used in the certificate SAN.}"

mkdir -p "${OPENVPN_DIR}/ccd"
cd "${OPENVPN_DIR}"

if [ ! -f server.conf ] && [ -f "${SERVER_CONF_TEMPLATE}" ]; then
  cp "${SERVER_CONF_TEMPLATE}" server.conf
fi

touch ipp.txt openvpn-status.log
openvpn --genkey --secret ta.key
openssl genpkey -algorithm ML-DSA-87 -out ca.key
openssl req -new -x509 -nodes -key ca.key -out ca.crt  -subj "/CN=MyVPN-CA" -days 3650

openssl genpkey -algorithm ML-DSA-87 -out server.key
openssl req -new -key server.key -out server.csr -subj "/CN=MyVPN-Server"

sed \
  -e "s/ENV_SERVER_DNS/${ENV_SERVER_DNS}/g" \
  -e "s/ENV_SERVER_IP/${ENV_SERVER_IP}/g" \
  "${SERVER_EXT_TEMPLATE}" > "${SERVER_EXT}"

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -extensions server -extfile "${SERVER_EXT}"

echo "generated in ${OPENVPN_DIR}: ca.key, ca.crt, server.key, server.crt"

