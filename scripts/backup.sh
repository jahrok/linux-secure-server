#!/usr/bin/env bash
# Creates a timestamped backup of /srv/project and keeps the latest 7.
set -euo pipefail

SRC="/srv/project"
DEST="/var/backups/project"
KEEP=7

mkdir -p "$DEST"
STAMP="$(date +%Y%m%d-%H%M%S)"
tar -czf "$DEST/project-$STAMP.tar.gz" -C "$SRC" .

# Rotation: delete everything older than the latest $KEEP backups
ls -1t "$DEST"/project-*.tar.gz | tail -n +$((KEEP + 1)) | xargs -r rm --

logger -t backup "Backup created: project-$STAMP.tar.gz"
echo "Backup created: $DEST/project-$STAMP.tar.gz"