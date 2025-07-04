COMPOSE_DIR := infra/docker
COMPOSE_COMMAND := docker compose -f $(COMPOSE_DIR)/docker-compose.yml --env-file infra/.env
MYPY_DIRS := libs $(foreach service,$(SERVICES),services/$(service)/src)

define compose_action
	@if [ -z "$(s)" ]; then \
		echo $(COMPOSE_COMMAND) $(1) $(e); \
		$(COMPOSE_COMMAND) $(1) $(e); \
	else \
		echo $(COMPOSE_COMMAND) $(1) $(s) $(e); \
		$(COMPOSE_COMMAND) $(1) $(s) $(e); \
	fi
endef

help:
	@awk 'BEGIN {FS = ":.*#"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?#/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^#@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

up: # compose up [s=<service>] [e="<extra> <extra2>"]
	$(call compose_action,up -d)

venv: # create/sync venv
	@uv sync --frozen --all-packages

add: # add python package to service p=<package> s=<service> [e="<extra> <extra2>"]
	@if [ -z "$(p)" ] || [ -z "$(s)" ]; then \
		echo "Usage: make add p=<package> s=<service> [e='<extra> <extra2>']"; \
		exit 1; \
	fi; \
	uv add $(p) --package $(s) $(e); \

lint: # run linters and formatters
	@uv run ruff check . && \
	uv run isort . --check-only && \
	uv run ruff format --check . && \
	$(foreach dir,$(MYPY_DIRS),uv run mypy $(dir) && echo $(dir);)

lint-fix: # run linters and formatters with fix
	@uv run ruff check . && \
	uv run isort . && \
	uv run ruff format . && \
	$(foreach dir,$(MYPY_DIRS),uv run mypy $(dir) && echo $(dir);)
