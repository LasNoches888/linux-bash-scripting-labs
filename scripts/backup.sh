#!/usr/bin/env bash
set -euo pipefail
SRC="${1:?usage: backup.sh <src> <dst>}"
DST="${2:?usage: backup.sh <src> <dst>}"
STAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$DST"
tar czf "$DST/backup_$STAMP.tar.gz" -C "$SRC" .
find "$DST" -name "backup_*.tar.gz" -mtime +7 -delete
echo "Backup -> $DST/backup_$STAMP.tar.gz"
