#!/usr/bin/env bash
# Configures UFW firewall and fail2ban for SSH.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }

ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 'Nginx HTTP'
ufw --force enable

cat > /etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled  = true
maxretry = 3
findtime = 10m
bantime  = 1h
EOF

systemctl enable --now fail2ban
systemctl restart fail2ban

echo "[OK] Firewall and fail2ban active"