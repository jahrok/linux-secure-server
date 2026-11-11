#!/usr/bin/env bash
# Hardens SSH. Run ONLY after verifying key-based login works.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }

# Named 00-* so it is read first (sshd uses the first value found)
install -m 644 "$(dirname "$0")/../config/00-hardening.conf" /etc/ssh/sshd_config.d/00-hardening.conf
sshd -t                           # validate config before restarting
systemctl restart ssh

echo "[OK] SSH hardened"