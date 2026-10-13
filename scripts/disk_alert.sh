#!/usr/bin/env bash
# Предупреждение о заполнении дисков.
#
# Использование: disk_alert.sh [порог_в_процентах]    (по умолчанию 80)
# Код возврата: 0 — все разделы ниже порога, 1 — есть разделы выше порога или ошибка.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

THRESHOLD="${1:-80}"
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 || THRESHOLD > 100 )); then
    die "Порог должен быть целым числом от 1 до 100, получено: $THRESHOLD"
fi

alerts=0
# df -P — переносимый формат (одна строка на раздел); пропускаем заголовок
while read -r _fs _size _used avail pct mount; do
    usage="${pct%\%}"
    [[ "$usage" =~ ^[0-9]+$ ]] || continue
    if (( usage >= THRESHOLD )); then
        log_warn "$mount: занято ${usage}% (порог ${THRESHOLD}%), свободно ${avail} КБ"
        alerts=$((alerts + 1))
    fi
done < <(df -P -x tmpfs -x devtmpfs | tail -n +2)

if (( alerts > 0 )); then
    exit 1
fi
log_info "Все разделы заполнены меньше чем на ${THRESHOLD}%"
