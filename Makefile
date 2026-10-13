SCRIPTS := $(shell find scripts tests -name '*.sh')

.PHONY: help syntax lint test check

help: ## Показать список целей
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-8s %s\n", $$1, $$2}'

syntax: ## Проверить синтаксис всех скриптов (bash -n)
	@for f in $(SCRIPTS); do bash -n "$$f" || exit 1; done; echo "Синтаксис в порядке"

lint: ## Статический анализ shellcheck
	shellcheck $(SCRIPTS)

test: ## Запустить тесты
	bash tests/run_tests.sh

check: syntax test ## Синтаксис + тесты
