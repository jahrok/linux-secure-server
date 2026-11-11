#!/usr/bin/env bash
# Installs packages, creates users/groups and a shared directory with least-privilege access.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }

apt update && apt upgrade -y
apt install -y nginx ufw fail2ban acl curl git

# Groups and users (no passwords: access is tested with sudo -u)
groupadd -f devs
groupadd -f auditors
id -u alice &>/dev/null || useradd -m -s /bin/bash -G devs alice
id -u bob   &>/dev/null || useradd -m -s /bin/bash -G auditors bob

# Shared directory: devs read/write, auditors read-only (ACL), others no access
mkdir -p /srv/project
chown root:devs /srv/project
chmod 2770 /srv/project          # setgid: new files inherit group "devs"
setfacl -m  g:auditors:rx /srv/project
setfacl -d -m g:auditors:rx /srv/project

# Least privilege: devs may only check/restart nginx
echo '%devs ALL=(root) NOPASSWD: /usr/bin/systemctl restart nginx, /usr/bin/systemctl status nginx' \
  > /etc/sudoers.d/devs
chmod 440 /etc/sudoers.d/devs
visudo -cf /etc/sudoers.d/devs

echo "[OK] Users, groups and permissions configured"