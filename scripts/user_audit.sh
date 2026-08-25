#!/usr/bin/env bash
echo "=== Пользователи с UID >= 1000 ==="
awk -F: '$3>=1000 && $3<65534 {print $1" (uid "$3")"}' /etc/passwd
echo "=== Члены группы sudo/wheel ==="
getent group sudo wheel 2>/dev/null
