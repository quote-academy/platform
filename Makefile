UID := $(shell id -u)
GID := $(shell id -g)
ENV = dev
INIT_FILE = false
BUILD_NO_CACHE = false

DOCKER_COMPOSE_BIN = docker-compose
DOCKER_COMPOSE = $(DOCKER_COMPOSE_BIN)

ifeq ($(DOCKER), local)
	API =
	DB =
	NGINX =
	ELASTIC =
	REDIS =
	RABBITMQ =
	NEO4J =
	CD_API =
else
	API = docker exec -ti $$(docker-compose ps -q api)
	DB = docker exec -ti $$(docker-compose ps -q db)
	NGINX = docker exec -ti $$(docker-compose ps -q nginx)
	ELASTIC = docker exec -ti $$(docker-compose ps -q elastic)
	REDIS = docker exec -ti $$(docker-compose ps -q redis)
	RABBITMQ = docker exec -ti $$(docker-compose ps -q rabbitmq)
	NEO4J = docker exec -ti $$(docker-compose ps -q neo4j)
	CD_API = cd /srv/api &&
endif

######### DOCKER #########

all: install initialize prepare

matrix-reload: initialize prepare

initialize: init-docker-compose init-docker init-api-parameters

prepare: api-prepare

api-prepare: api-clean-cache-and-logs api-composer-install api-elastic-curator api-db-reset api-db-fixtures-load api-elastic-index-data

######### INIT #########

install: install-api

install-api:
	git clone git@github.com:quote-academy/api.git && cd ./api/ && git remote add upstream git@github.com:quote-academy/api.git && git remote rm origin

init-docker-compose:
ifeq ($(INIT_FILE), true)
	cp docker-compose.yml.dist docker-compose.yml
else
	@echo " -> Using your [PLATFORM] docker-compose.yml file"
endif

init-docker:
	docker-compose down
ifeq ($(BUILD_NO_CACHE), true)
	docker-compose build --no-cache --pull --force-rm
else
	docker-compose build
endif
	docker-compose up -d

init-api-parameters:
ifeq ($(INIT_FILE), true)
	cd api && cp app/config/parameters.yml.docker app/config/parameters.yml
else
	@echo " -> Using your [API] parameters.yml file"
endif

######### BASH COMMAND IN CONTAINERS #########

bash-api:
	$(API) bash

bash-db:
	$(DB) bash

bash-nginx:
	$(NGINX) sh

bash-elastic:
	$(ELASTIC) bash

bash-redis:
	$(REDIS) bash

######### DATABASE #########

api-db-reset: api-db-drop-schema api-db-create-schema

api-db-init:
	$(API) bin/console quote:init || true

api-db-create:
	$(API) bin/console doctrine:database:create --if-not-exists --no-interaction --env $(ENV) || true

api-db-drop:
	$(API) bin/console doctrine:database:drop --force -n --env=$(ENV) || true

api-db-create-schema:
	$(API) bin/console doctrine:schema:create --no-interaction --ansi --env=$(ENV) || true

api-db-drop-schema:
	$(API) bin/console doctrine:schema:drop --no-interaction --force --full-database --ansi --env=$(ENV) || true

api-db-migrate:
	$(API) bin/console doctrine:migrations:migrate -n --env=$(ENV) || true

api-db-fixtures-load:
	$(API) bin/console hautelook_alice:doctrine:fixtures:load --no-interaction --ansi --no-sync --env=$(ENV) || true

######### REDIS #########

api-redis-clean:
	$(REDIS) redis-cli flushdb

front-redis-clean:
	$(REDIS) redis-cli flushdb

######### ELASTICSEARCH #########

api-elastic-reindex-all: elastic-restart elastic-curator elastic-index-data

api-elastic-restart:
	$(ELASTIC) service elasticsearch restart || true

api-elastic-reset-indexes:
	$(API) bin/console fos:elastic:reset --force --ansi || true

# deleting all elasticsearch indices
api-elastic-curator:
	$(ELASTIC) curator --host localhost delete indices --all-indices || true

api-elastic-index-data:
	$(API) bin/console fos:elastica:populate --ansi --env $(ENV) || true

api-elastic-status:
	$(ELASTIC) curl -sS -XGET 'http://localhost:9200/_cluster/health?pretty'

######### LAUNCHING TESTS #########

api-phpunit-all: api-phpunit

api-phpunit:
	$(API) bin/phpunit --colors

######### API #########

api-clean-cache-and-logs: api-clean-cache api-clean-logs

api-clean-cache:
	$(API) sh -c "$(CD_API) mkdir -p var/cache && rm -rf var/cache/* && chmod 777 var/cache || true"

api-clean-logs:
	$(API) sh -c "$(CD_API) mkdir -p var/logs && rm -rf var/logs/* && chmod 777 var/logs || true"

api-cache-clear:
	$(API) bin/console cache:clear --env=$(ENV) --no-debug --ansi || true

api-composer-install:
	@$(API) composer install --ansi --no-interaction || true

api-composer-update:
	$(API) composer update || true

api-php-fpm-restart:
	$(API) service php5-fpm restart

######### GRAPH #################

api-graph-populate:
	$(API) bin/console mr:graph:populate || true
