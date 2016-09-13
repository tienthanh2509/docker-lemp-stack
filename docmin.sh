#!/bin/bash

# Docker binary
BIN_DOCKER="docker"
BIN_DOCKER_COMPOSE="build/docker-compose"
COMPOSE_FILE_BUILD="build/compose-build.yml"
COMPOSE_FILE_UP_DEVELOPMENT="compose-up-development.yml"
COMPOSE_FILE_UP_PRODUCTION="compose-up-production.yml"

# ENV
NAMESPACE="tdmu"

#--------------------------------------------------------
# Docker container name with namespace
# Main service
CONTAINER_NGINX="nginx"
CONTAINER_PHP56=$NAMESPACE"_php56"
CONTAINER_PHP70=$NAMESPACE"_php70"
# Data
CONTAINER_BACKUP=$NAMESPACE"_backup"
CONTAINER_MARIADB=$NAMESPACE"_mariadb"
CONTAINER_WWWDATA=$NAMESPACE"_wwwdata"
# Cache service
CONTAINER_MEMCACHED=$NAMESPACE"_memcached"
CONTAINER_REDIS=$NAMESPACE"_redis"
# Dev Tools
CONTAINER_MAILCATCHER=$NAMESPACE"_mailcatcher"

#--------------------------------------------------------
# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

boldblack='\E[1;30;40m'
boldred='\E[1;31;40m'
boldgreen='\E[1;32;40m'
boldyellow='\E[1;33;40m'
boldblue='\E[1;34;40m'
boldmagenta='\E[1;35;40m'
boldcyan='\E[1;36;40m'
boldwhite='\E[1;37;40m'

#  Reset text attributes to normal without clearing screen.
Reset="tput sgr0"

# Coloured-echo.
# Argument $1 = message
# Argument $2 = color
cecho () {
	color=$2
	message=$1
	echo -e "$color$message" ; $Reset
	return
}
#--------------------------------------------------------

# Backup function
#container_data - Create a backup of the shared containers data in data/backups/'
#db       - Create a backup of the MariaDB instance in data/backups/'
#www            - Create a backup of the wwwdata container volum in data/backups/'
backup() {
	case "$1" in
		"all") $(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupdata.sh ;;
		"db") $(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupdatabase.sh ;;
		"www") $(BIN_DOCKER) exec -it $(CONTAINER_BACKUP) /opt/backupwww.sh ;;
		*) echo "INVALID ARGUMENTS!" ;;
	esac
}

# backup, memcached, redis, nginx, php56, php70, mariadb, wwwdata, mailcatcher
connect() {
	container="$1"
	$(BIN_DOCKER) exec -it $(container) bash
}

# Reload main service
reload() {
	case "$1" in
		"nginx") $(BIN_DOCKER) exec -it $(CONTAINER_NGINX) service nginx reload ;;
		"php56") $(BIN_DOCKER) exec -it $(CONTAINER_PHP56) service php5-fpm reload ;;
		"php70") $(BIN_DOCKER) exec -it $(CONTAINER_PHP70) service php7.0-fpm reload ;;
		*) echo "INVALID ARGUMENTS!" ;;
	esac
}

# Admin
docker_clean() {
	case "$1" in
		"containers") $(BIN_DOCKER) stop `$(BIN_DOCKER) ps -a -q` && $(BIN_DOCKER) rm `$(BIN_DOCKER) ps -a -q` ;;
		"images") $(BIN_DOCKER) rmi -f `$(BIN_DOCKER) images -q)` ;;
		"all") docker_clean containers && docker_clean images ;;
		*) echo "INVALID ARGUMENTS!" ;;
	esac
}

pull() {
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_PRODUCTION) pull
}

build() {
	$(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_BUILD) build
}

deploy() {
	case "$1" in
		"dev") $(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_DEVELOPMENT) up -d ;;
		*) $(BIN_DOCKER_COMPOSE) -f $(COMPOSE_FILE_UP_PRODUCTION) up -d ;;
	esac	
}

#
show_menu() {
while :
do
	cecho "--------------------------------------------------------" $boldyellow
	cecho "                 Docker LEMP Stack v1.0                 " $boldgreen
	cecho "--------------------------------------------------------" $boldyellow
	echo 'Support:'
	echo 'Nginx, PHP 5.6/7, MariaDB, Memcached, Redis'
	echo "Current namespace: $NAMESPACE"
	cecho "--------------------------------------------------------" $boldyellow
	echo '# Deploy'
	echo '1. pull          - Pull all the newest images'
	echo '2. deploy dev    - Start development environment. Will recreate linked containers of new services, using compose-up-development.yml'
	echo '3. deploy prod   - The same as up_dev but then for your production environment, using compose-up-production.yml'
	echo ''
	echo '# Maintenance'
	echo 'Create a backup of:'
	echo '11. backup all   - the shared containers data in data/backups/'
	echo '12. backup db    - the MariaDB instance in data/backups/'
	echo '13. backup www   - the wwwdata container volum in data/backups/'
	echo ''
	echo '# Reload container'
	echo '21. reload nginx - Reload the nginx configuration files (service nginx reload)'
	echo '22. reload php56 - Reload PHP FPM of the php56 service'
	echo '23. reload php70 - Reload PHP FPM of the php70 service'
	echo ''
	echo '# Container Bash Shell'
	echo 'connect [service]'
	echo 'connect backup    5. connect memcached       9. connect mailcatcher'
	echo 'connect nginx     6. connect redis'
	echo 'connect php56     7. connect mariadb'
	echo 'connect php70     8. connect wwwdata'
	cecho "--------------------------------------------------------" $boldyellow
	read -ep "Enter option [ 1 - 23 ] " option

	case "$option" in
		1) pull ;;

		2) deploy dev ;;
		3) deploy prod ;;

		4) backup all ;;
		5) backup db ;;
		6) backup www ;;

		7) reload nginx ;;
		8) reload php56 ;;
		9) reload php70 ;;
		exit) exit 0 ;;
	esac

done
}

show_menu