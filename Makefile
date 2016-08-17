BIN_DOCKER = 'docker'
BIN_DOCKER_COMPOSE = 'docker-compose'

COMPOSE_FILE_BUILD = 'compose-build.yml'
COMPOSE_FILE_UP_DEVELOPMENT = 'compose-up-development.yml'
COMPOSE_FILE_UP_PRODUCTION = 'compose-up-production.yml'

CONTAINER_BACKUP = backup
CONTAINER_MAILCATCHER = mailcatcher
CONTAINER_MARIADB = mariadb
CONTAINER_MEMCACHED = memcached
CONTAINER_NGINX = nginx
CONTAINER_PHP56 = php56
CONTAINER_PHP56CLI = php56cli
CONTAINER_PHP70 = php70
CONTAINER_PHP70CLI = php70cli
CONTAINER_RABBITMQ = rabbitmq
CONTAINER_REDIS = redis
CONTAINER_WWWDATA = wwwdata

default:
	@echo '=================================================='
	@echo 'Docker LEMP Stack v1.0                            '
	@echo '----------------------'
	@echo 'Support:'
	@echo 'Nginx, PHP 5.6/7, MariaDB, Memcached, Redis'
	@echo '----------------------'
	@echo 'Use `make [job]`'
	@echo '----------------------'
	@echo 'pull       - Pull all the newest images'
	@echo 'up_dev     - Start development environment. Will recreate linked containers of new services, using compose-up-development.yml'
	@echo 'up_prod    - The same as up_dev but then for your production environment, using compose-up-production.yml'
	@echo ''
	@echo '# Maintenance'
	@echo 'backup_container_data - Create a backup of the shared containers data in data/backups/'
	@echo 'backup_database       - Create a backup of the MariaDB instance in data/backups/'
	@echo 'backup_www            - Create a backup of the wwwdata container volum in data/backups/'
	@echo ''
	@echo '# Reload container'
	@echo 'reload_nginx  - Reload the nginx configuration files (service nginx reload)'
	@echo 'reload_php_56 - Reload PHP FPM of the php56 service'
	@echo 'reload_php_70 - Reload PHP FPM of the php70 service'
	@echo ''
	@echo '# Container Bash Shell'
	@echo '1. connect_backup             5. connect_memcached           9. connect_mailcatcher'
	@echo '2. connect_nginx              6. connect_redis              10. connect_rabbitmq'
	@echo '3. connect_php56              7. connect_mariadb'
	@echo '4. connect_php70              8. connect_wwwdata'
	@echo '=================================================='

#####################################################################
# App init
pull:
	$(BIN_DOCKER) pull phusion/baseimage:latest
	$(BIN_DOCKER) pull $(CONTAINER_REDIS)
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_PRODUCTION) pull

build:
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_BUILD) build

up_dev:
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_DEVELOPMENT) up -d

up_prod:
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_PRODUCTION) up -d

# App control
reload_php_56:
	$(BIN_DOCKER) exec -it $(CONTAINER_PHP56) service php5-fpm reload

reload_php_70:
	$(BIN_DOCKER) exec -it $(CONTAINER_PHP70) service php7.0-fpm reload

reload_nginx:
	$(BIN_DOCKER) exec -it $(CONTAINER_NGINX) service nginx reload

# Clean up
clear_all: clear_containers clear_images

clear_containers:
	$(BIN_DOCKER) stop `$(BIN_DOCKER) ps -a -q` && $(BIN_DOCKER) rm `$(BIN_DOCKER) ps -a -q`

clear_images:
	$(BIN_DOCKER) rmi -f `$(BIN_DOCKER) images -q)`

#####################################################################
# Maintenance
backup_container_data:
	$(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupdata.sh

backup_database:
	$(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupdatabase.sh

backup_www:
	$(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupwww.sh

#####################################################################
# Bash Shell
connect_backup:
	$(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) bash

#
connect_memcached:
	$(BIN_DOCKER) exec -it $(CONTAINER_MEMCACHED) bash

connect_redis:
	$(BIN_DOCKER) exec -it $(CONTAINER_REDIS) bash

#
connect_nginx:
	$(BIN_DOCKER) exec -it $(CONTAINER_NGINX) bash

#
connect_php56:
	$(BIN_DOCKER) exec -it $(CONTAINER_PHP56) bash

connect_php70:
	$(BIN_DOCKER) exec -it $(CONTAINER_PHP70) bash

#
connect_mariadb: 
	$(BIN_DOCKER) exec -it $(CONTAINER_MARIADB) bash

#
connect_wwwdata:
	$(BIN_DOCKER) exec -it $(CONTAINER_WWWDATA) bash

#
connect_mailcatcher:
	$(BIN_DOCKER) exec -it $(CONTAINER_MAILCATCHER) bash

connect_rabbitmq:
	$(BIN_DOCKER) exec -it $(CONTAINER_RABBITMQ) bash