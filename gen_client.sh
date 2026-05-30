#!/usr/bin/env bash

set -euo pipefail

OPENVPN_DIR="/etc/openvpn"
CLIENT_ID="${1:-${CLIENT_ID:-client-${RANDOM}}}"

case "${CLIENT_ID}" in
  ''|*[!A-Za-z0-9._-]*)
    echo "Client ID must contain only letters, numbers, dots, underscores, or hyphens." >&2
    exit 1
    ;;
esac

CLIENT_DIR="${OPENVPN_DIR}/clients/${CLIENT_ID}"
CLIENT_CN="MyVPN-Client-${CLIENT_ID}"
CLIENT_EXT="${CLIENT_EXT:-/client.ext}"

for required_file in "${OPENVPN_DIR}/ca.crt" "${OPENVPN_DIR}/ca.key" "${OPENVPN_DIR}/ta.key"; do
  if [ ! -f "${required_file}" ]; then
    echo "Missing ${required_file}. Run /gen_cert.sh first." >&2
    exit 1
  fi
done

mkdir -p "${OPENVPN_DIR}/ccd" "${CLIENT_DIR}"
cd "${CLIENT_DIR}"

for generated_file in client.key client.crt; do
  if [ -e "${generated_file}" ] && [ "${FORCE:-0}" != "1" ]; then
    echo "Refusing to overwrite ${CLIENT_DIR}/${generated_file}. Set FORCE=1 to regenerate this client." >&2
    exit 1
  fi
done

openssl genpkey -algorithm ML-DSA-87 -out client.key
openssl req -new -key client.key -out client.csr -subj "/CN=${CLIENT_CN}"
openssl x509 -req -in client.csr -CA "${OPENVPN_DIR}/ca.crt" -CAkey "${OPENVPN_DIR}/ca.key" -CAcreateserial -out client.crt -extensions client -extfile "${CLIENT_EXT}"

cp "${OPENVPN_DIR}/ca.crt" "${OPENVPN_DIR}/ta.key" "${CLIENT_DIR}/"

touch "${OPENVPN_DIR}/ccd/${CLIENT_CN}"

echo "generated in ${CLIENT_DIR}: client.key, client.crt"
