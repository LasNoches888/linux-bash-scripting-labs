# linux-bash-scripting-labs

Практические задачи по bash: от базовых до системного администрирования.

## Скрипты
- `scripts/backup.sh` — инкрементальный бэкап директории с ротацией
- `scripts/sysinfo.sh` — отчёт о состоянии системы
- `scripts/log_parser.sh` — анализ логов nginx (топ IP/статусов)
- `scripts/user_audit.sh` — аудит пользователей и sudo-прав

## Дополнительно
- `scripts/healthcheck.sh` — проверка HTTP-адреса или TCP-порта с понятными кодами возврата.
- `scripts/disk_alert.sh` — предупреждение о заполнении дисков по порогу.
- `scripts/lib/common.sh` — общие функции (`log_info`, `die`, `require_cmd`).
- `labs/` — четыре учебные лабы: кавычки и переменные, условия и циклы, функции и `trap`, обработка текста.
- `tests/run_tests.sh` + `Makefile` — `make check` проверяет синтаксис и запускает тесты.
