# Лаба 2: Условия и циклы

## Задания

1. Напишите скрипт, который принимает путь и сообщает: файл это, каталог или ничего не существует.
2. Пройдите по всем `*.log` в каталоге и выведите количество строк в каждом.
3. Прочитайте файл построчно и пропустите пустые строки и комментарии (`#`).
4. Повторяйте проверку сервиса до 5 раз с паузой 2 секунды; выйдите с кодом 0 при первом успехе.
5. Разберите аргументы `-v` (подробный вывод) и `-n <число>` через `getopts`.

## Решения

```bash
# 1.
path="${1:?usage: kind.sh <path>}"
if [[ -f "$path" ]]; then echo "файл"
elif [[ -d "$path" ]]; then echo "каталог"
else echo "не существует"
fi

# 2. Глоб вместо `ls | ...` — безопасно для имён с пробелами
for f in ./*.log; do
    [[ -e "$f" ]] || continue          # если файлов нет, глоб остаётся буквальной строкой
    printf '%s: %s строк\n' "$f" "$(wc -l <"$f")"
done

# 3. IFS= и -r сохраняют пробелы и обратные слэши
while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "$line"
done <config.txt

# 4. Повторные попытки (см. scripts/healthcheck.sh)
for attempt in {1..5}; do
    if ./scripts/healthcheck.sh localhost:8080 2; then exit 0; fi
    echo "попытка $attempt не удалась" >&2
    sleep 2
done
exit 1

# 5.
verbose=0; count=1
while getopts "vn:" opt; do
    case "$opt" in
        v) verbose=1 ;;
        n) count="$OPTARG" ;;
        *) echo "usage: $0 [-v] [-n число]" >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))
```

## Частые ошибки

| Ошибка | Правильно |
|--------|-----------|
| `[ $a = $b ]` с пустой переменной | `[[ "$a" == "$b" ]]` |
| `for f in $(ls)` | `for f in ./*` |
| `cat file \| while read …` (переменные теряются в подоболочке) | `while read … done < file` |
| `if [ $n > 5 ]` (это перенаправление в файл `5`) | `if (( n > 5 ))` |
