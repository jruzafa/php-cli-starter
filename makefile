include .env
export $(shell sed 's/=.*//' .env)

## Docker
CURRENT_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DOCKER_PHP_EXEC=@docker run -v $(CURRENT_DIR):/var/www $(CONTAINER_NAME):latest

.DEFAULT_GOAL := help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: env
env:
	@echo 'Current environment: $(APP_ENV)'

.PHONY: clear
clear: ## Remove service containers
	@docker rm -f $(docker ps --filter name=$(CONTAINER_NAME) -a -q)

.PHONY: build
build: ## Docker up in foreground mode
	@docker build --no-cache --tag $(CONTAINER_NAME) .

.PHONY: composer_init
composer_init: ## Composer init
	$(DOCKER_PHP_EXEC) composer init --name php/${CONTAINER_NAME}

.PHONY: install
install: ## Composer install
	$(DOCKER_PHP_EXEC) composer install

.PHONY: update
update: ## Composer update
	$(DOCKER_PHP_EXEC) composer update

.PHONY: run
run: ## run
	$(DOCKER_PHP_EXEC) php -f src/index.php
