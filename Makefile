# .PHONY — цели, которые не являются файлами (всегда выполняются)
.PHONY: db-build db-up db-down goose
.PHONY: status up up-by-one up-to down down-to redo
.PHONY: migration-create-sql migration-create-go create-core debug-env
.PHONY: test-db-up test-db-down migrate-check
.PHONY: swagger-gen
.PHONY: build-app app-up app-down

# ========== Настройки ==========
MIGRATIONS_DIR := ./migrations
COMPOSE_ARGS := --env-file .env.local -f docker-compose.yml
COMPOSE := docker compose $(COMPOSE_ARGS)
GOOSE_SERVICE := goose

# ========== Базовые команды ==========

db-build:
	$(COMPOSE) build postgres goose

db-up: db-build
	$(COMPOSE) up -d postgres
	$(COMPOSE) up -d goose

db-down:
	$(COMPOSE) down

# ========== Миграции ==========

status:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) status

up:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) up

up-by-one:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) up-by-one

up-to:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Укажите VERSION: make up-to VERSION=5"; \
		exit 1; \
	fi
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) up-to $(VERSION)

down:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) down

down-to:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Укажите VERSION: make down-to VERSION=3"; \
		exit 1; \
	fi
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) down-to $(VERSION)

redo:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) redo

# ========== Создание миграций ==========

migration-create-sql:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Укажите NAME: make migration-create-sql NAME=add_users_table"; \
		exit 1; \
	fi
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) create $(NAME) sql

migration-create-go:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Укажите NAME: make migration-create-go NAME=add_users_table"; \
		exit 1; \
	fi
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) create $(NAME) go

create-core:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Укажите NAME: make create-core NAME=create_users"; \
		exit 1; \
	fi
	@if [ ! -f scripts/create-core-template.sql ]; then \
		echo "❌ Файл шаблона не найден: scripts/create-core-template.sql"; \
		exit 1; \
	fi
	@echo "🔒 Создаём core-миграцию: $(NAME)"
	$(COMPOSE) run --rm $(GOOSE_SERVICE) goose -dir $(MIGRATIONS_DIR) create $(NAME) sql
	@MIG_FILE=$$(ls -t $(MIGRATIONS_DIR)/[0-9]*_$(NAME).sql | head -n1); \
	if [ -n "$$MIG_FILE" ]; then \
		cat scripts/create-core-template.sql > "$$MIG_FILE"; \
		echo "✅ Core-миграция создана: $$MIG_FILE"; \
	else \
		echo "❌ Не найдена созданная миграция!"; \
		exit 1; \
	fi

debug-env:
	$(COMPOSE) run --rm $(GOOSE_SERVICE) env | grep -E "GOOSE|POSTGRES"

# ========== Swagger ==========

swagger-gen:
	swag init --generalInfo main.go --dir cmd/server,internal

# ========== Приложение ==========

# Файл-маркер, который обновляется при изменении исходников
APP_BUILD_MARKER := .build/app.marker

# Зависимости: все .go файлы и go.mod/go.sum
GO_SOURCES := $(shell find . -name '*.go' -not -path './vendor/*')
GO_MOD_FILES := go.mod go.sum

# Цель: обновить маркер, если исходники изменились
$(APP_BUILD_MARKER): $(GO_SOURCES) $(GO_MOD_FILES) ../application_aggregator/Dockerfile
	@mkdir -p .build
	@echo "📦 Собираем приложение (изменены исходники)..."
	$(COMPOSE) build app
	@touch $@

# Сборка только если нужно
build-app: $(APP_BUILD_MARKER)

app-up: build-app
	$(COMPOSE) --profile app up -d

app-down:
	$(COMPOSE) --profile app stop
#	$(COMPOSE) --profile app rm -f

# ========== Тестовая БД ==========

test-db-up:
	@cp -n .env.test.example .env.test 2>/dev/null || true
	docker compose --env-file .env.test -f docker-compose.test.yml up -d postgres-test

test-db-down:
	docker compose --env-file .env.test -f docker-compose.test.yml down -v

migrate-check:
	@echo "🔍 Валидация миграций (накат → откат → накат)..."
	@cp -n .env.test.example .env.test 2>/dev/null || true
	docker compose --env-file .env.test -f docker-compose.test.yml up -d postgres-test
	@sleep 5
	@echo "→ Накат всех миграций..."
	docker compose --env-file .env.test -f docker-compose.test.yml run --rm goose-test goose -dir ./migrations up
	@echo "→ Откат всех миграций..."
	docker compose --env-file .env.test -f docker-compose.test.yml run --rm goose-test goose -dir ./migrations down-to 0
	@echo "→ Повторный накат..."
	docker compose --env-file .env.test -f docker-compose.test.yml run --rm goose-test goose -dir ./migrations up
	@echo "✅ Валидация пройдена! Все миграции идемпотентны."
	docker compose --env-file .env.test -f docker-compose.test.yml down
