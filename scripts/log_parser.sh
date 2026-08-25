#!/usr/bin/env bash
# Топ-10 IP и распределение HTTP-статусов из access.log
set -euo pipefail
LOG="${1:?usage: log_parser.sh <access.log>}"
echo "=== Top 10 IP ==="
awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -10
echo "=== HTTP статусы ==="
awk '{print $9}' "$LOG" | sort | uniq -c | sort -rn
