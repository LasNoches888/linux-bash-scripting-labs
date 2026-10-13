#!/usr/bin/env bash
# Простые тесты скриптов без внешних зависимостей. Запуск: bash tests/run_tests.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); echo "  ok   - $1"; }
not_ok() { FAIL=$((FAIL + 1)); echo "  FAIL - $1"; }

# assert_contains <имя теста> <вывод> <ожидаемая подстрока>
assert_contains() {
    if grep -qF -- "$3" <<<"$2"; then ok "$1"; else not_ok "$1 (нет '$3' в выводе)"; fi
}

# assert_status <имя теста> <ожидаемый код> <фактический код>
assert_status() {
    if [[ "$2" == "$3" ]]; then ok "$1"; else not_ok "$1 (ожидался код $2, получен $3)"; fi
}

echo "log_parser.sh"
out="$("$ROOT/scripts/log_parser.sh" "$ROOT/tests/data/access.log")"
assert_contains "самый активный IP — 10.0.0.1 (3 запроса)" "$out" "3 10.0.0.1"
assert_contains "статус 200 встречается 3 раза" "$out" "3 200"
assert_contains "статус 500 присутствует" "$out" "1 500"

echo "backup.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/src" "$tmp/dst"
echo "hello" >"$tmp/src/file.txt"
"$ROOT/scripts/backup.sh" "$tmp/src" "$tmp/dst" >/dev/null
archive="$(ls "$tmp"/dst/backup_*.tar.gz 2>/dev/null | head -1)"
if [[ -n "$archive" ]]; then ok "архив создан"; else not_ok "архив не создан"; fi
if [[ -n "$archive" ]] && tar tzf "$archive" | grep -q "file.txt"; then
    ok "в архиве есть file.txt"
else
    not_ok "в архиве нет file.txt"
fi

echo "healthcheck.sh"
"$ROOT/scripts/healthcheck.sh" >/dev/null 2>&1
assert_status "без аргументов — код 2" 2 $?
"$ROOT/scripts/healthcheck.sh" localhost:abc >/dev/null 2>&1
assert_status "неверный порт — код 2" 2 $?
"$ROOT/scripts/healthcheck.sh" localhost:1 1 >/dev/null 2>&1
assert_status "закрытый порт — код 1" 1 $?

echo "disk_alert.sh"
"$ROOT/scripts/disk_alert.sh" abc >/dev/null 2>&1
assert_status "нечисловой порог — код 1" 1 $?
"$ROOT/scripts/disk_alert.sh" 0 >/dev/null 2>&1
assert_status "порог 0 отклоняется — код 1" 1 $?

echo
echo "Итого: успешно $PASS, провалено $FAIL"
[[ "$FAIL" -eq 0 ]]
