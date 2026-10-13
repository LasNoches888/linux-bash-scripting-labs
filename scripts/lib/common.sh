#!/usr/bin/env bash
# Общие функции для скриптов лабы.
# Подключение:  source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

if [[ -t 2 ]]; then
    _C_RED=$'\033[31m'
    _C_YELLOW=$'\033[33m'
    _C_RESET=$'\033[0m'
else
    _C_RED=""
    _C_YELLOW=""
    _C_RESET=""
fi

_ts() { date '+%F %T'; }

log_info() { printf '%s [INFO]  %s\n' "$(_ts)" "$*" >&2; }
log_warn() { printf '%s %s[WARN]%s  %s\n' "$(_ts)" "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
log_error() { printf '%s %s[ERROR]%s %s\n' "$(_ts)" "$_C_RED" "$_C_RESET" "$*" >&2; }

# die <сообщение> — вывести ошибку и завершить скрипт с кодом 1
die() {
    log_error "$*"
    exit 1
}

# require_cmd <команда>... — убедиться, что нужные программы установлены
require_cmd() {
    local cmd
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || die "Не найдена команда: $cmd"
    done
}
