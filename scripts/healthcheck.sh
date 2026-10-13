#!/usr/bin/env bash
# Проверка доступности сервиса по HTTP(S) или TCP-порту.
#
# Использование:
#   healthcheck.sh http://localhost:8080/health [таймаут_сек]
#   healthcheck.sh localhost:5432 [таймаут_сек]
#
# Коды возврата: 0 — сервис доступен, 1 — недоступен, 2 — неверные аргументы.
# Годится для cron и systemd-таймеров (см. linux-sysadmin-labs, лаба 03).
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

TARGET="${1:-}"
TIMEOUT="${2:-3}"

if [[ -z "$TARGET" ]]; then
    echo "usage: healthcheck.sh <http(s)://url | host:port> [timeout]" >&2
    exit 2
fi
if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || (( TIMEOUT < 1 )); then
    echo "Таймаут должен быть целым числом секунд >= 1" >&2
    exit 2
fi

check_http() {
    require_cmd curl
    curl -fsS -o /dev/null --max-time "$TIMEOUT" "$1"
}

check_tcp() {
    local host="${1%:*}" port="${1##*:}"
    if [[ -z "$host" || "$host" == "$1" ]] || ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Ожидается формат host:port, получено: $1" >&2
        exit 2
    fi
    # Хост и порт передаются позиционными аргументами, а не подставляются в строку команды
    timeout "$TIMEOUT" bash -c 'exec 3<>"/dev/tcp/$0/$1"' "$host" "$port" 2>/dev/null
}

case "$TARGET" in
    http://* | https://*) check=check_http ;;
    *) check=check_tcp ;;
esac

if "$check" "$TARGET"; then
    log_info "OK: $TARGET доступен"
else
    log_error "FAIL: $TARGET недоступен (таймаут ${TIMEOUT}с)"
    exit 1
fi
