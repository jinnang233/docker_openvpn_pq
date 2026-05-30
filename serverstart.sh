#!/usr/bin/env bash

set -euo pipefail

SUB_IP_RANGE="${SUB_IP_RANGE:-10.192.0.0/24}"
OUT_IFACE="${OUT_IFACE:-eth0}"
OPENVPN_DIR="${OPENVPN_DIR:-/etc/openvpn}"

if [ ! -f "${OPENVPN_DIR}/server.conf" ] && [ -f /server.conf ]; then
  cp /server.conf "${OPENVPN_DIR}/server.conf"
fi

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
