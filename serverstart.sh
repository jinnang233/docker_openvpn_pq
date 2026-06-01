#!/usr/bin/env bash

set -euo pipefail

cat >&2 <<'EOF'
======================================================================
  WARNING: AI-GENERATED CODE - REVIEW BEFORE USE
======================================================================

  This script and related configuration were generated with AI assistance.

  Review and test the code, configuration, cryptographic choices, and
  deployment commands carefully before using them. You are responsible
  for confirming that they are correct, secure, and appropriate for your
  environment.

  For better assurance, clone this repository, review the code yourself,
  and build the Docker image locally before using it.

  If you discover any code security issues, or any copyright or licensing
  concerns, please report them in Issues.

  Thank you for your understanding.

======================================================================

EOF

SUB_IP_RANGE="${SUB_IP_RANGE:-10.192.0.0/24}"
OUT_IFACE="${OUT_IFACE:-eth0}"
OPENVPN_DIR="/etc/openvpn"

mkdir -p "${OPENVPN_DIR}"

if [ ! -f "${OPENVPN_DIR}/server.conf" ] && [ -f /server.conf ]; then
  cp /server.conf "${OPENVPN_DIR}/server.conf"
fi

for required_file in ca.crt server.crt server.key ta.key; do
  if [ ! -f "${OPENVPN_DIR}/${required_file}" ]; then
    echo "Missing ${OPENVPN_DIR}/${required_file}. Run /gen_cert.sh with a persistent volume first." >&2
    exit 1
  fi
done

ensure_rule() {
  local table="${1}"
  shift

  if [ -n "${table}" ]; then
    iptables -t "${table}" -C "$@" 2>/dev/null || iptables -t "${table}" -A "$@"
  else
    iptables -C "$@" 2>/dev/null || iptables -A "$@"
  fi
}

ensure_rule "" FORWARD -i tun0 -o "${OUT_IFACE}" -s "${SUB_IP_RANGE}" -m conntrack --ctstate NEW -j ACCEPT
ensure_rule "" FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ensure_rule nat POSTROUTING -o "${OUT_IFACE}" -s "${SUB_IP_RANGE}" -j MASQUERADE

mkdir -p /dev/net
[ -e /dev/net/tun ] || mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

exec openvpn --config "${OPENVPN_DIR}/server.conf"
