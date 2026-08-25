#!/usr/bin/env bash
echo "=== System Info ==="
echo "Host:   $(hostname)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "CPU load:$(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1-3)"
echo "Memory:"; free -h 2>/dev/null || vm_stat
echo "Disk:";   df -h / 2>/dev/null
