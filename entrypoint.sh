#!/bin/bash

# Fix de permisos en OSX. Para que funcione hay que definir la variable de entorno OSX
if [ ! -z "$OSX" ] && [ -z "`grep docker /etc/apache2/apache2.conf`" ]; then
	# Using under boot2docker, fix rights
	echo "Using 'docker/staff' for Apache2 in boot2docker . . ."

	# Add a user for Apache2
	useradd -u 1000 -g 50 docker

	# Use the uid 1000 & gid 50 for Apache2
	sed -i 's/User www-data/User docker/' /etc/apache2/apache2.conf
	sed -i 's/Group www-data/Group staff/' /etc/apache2/apache2.conf
fi

if [ ! -f /root/.composer/auth.json ]; then
    mkdir -p /root/.composer
    echo "{" > /root/.composer/auth.json;
    if [ ! -z ${GIT_TOKEN_USER} ]; then
        echo "\"github-oauth\": {\"github.com\": \"${GIT_TOKEN_USER}\"}" >> /root/.composer/auth.json;
        if [ ! -z ${COMPOSER_SIU_USER} ]; then
            echo ", " >> /root/.composer/auth.json;
        fi
    fi    

    #Si no esta configurado el acceso composer a SIU, y esta presente el parametro, configurarlo
    if [ ! -z ${COMPOSER_SIU_USER} ] && [ ! -z ${COMPOSER_SIU_PASS} ]; then
        echo "\"http-basic\":{\"gitlab.siu.edu.ar\":{\"username\":\"${COMPOSER_SIU_USER}\",\"password\":\"${COMPOSER_SIU_PASS}\"}}" >> /root/.composer/auth.json;
    fi
    echo "}"  >> /root/.composer/auth.json;
fi

DOCKER_STATUS_PATH=/var/local/docker-data/containers-status
mkdir -p $DOCKER_STATUS_PATH

if [ -z "${DOCKER_WAIT_FOR}" ]; then
	echo "Starting $DOCKER_NAME...";
else
        echo "Waiting for ${DOCKER_WAIT_FOR}";
	while : ; do
		[[ -f "$DOCKER_STATUS_PATH/$DOCKER_WAIT_FOR" ]] && break;		
		sleep 10;
		#echo " (-.-) bored..";
	done
	echo "Wait finished, starting $DOCKER_NAME...";
fi
chmod -R a+rw $DOCKER_STATUS_PATH

for entrypoint in /entrypoint.d/*.sh
do
    if [ -f $entrypoint -a -x $entrypoint ]
    then
        $entrypoint
    fi
done

if [ ! -z $ENABLE_SSL ] && [ $ENABLE_SSL == 'true' ]; then
    if [ ! -n "$(find /etc/apache2 -maxdepth 1 -name 'ssl.*' -print -quit)" ]; then
        mkdir /etc/apache2/ssl.crt;
        mkdir /etc/apache2/ssl.key;        
    else
        echo 'Directorio existente...prosiguiendo ';
    fi

    if [ ! -f /etc/apache2/sites-available/$DOCKER_NAME.conf ]; then
        echo 'Activando configuración SSL.... ';
        cp /etc/apache2/localhost_template.ssl /etc/apache2/sites-available/$DOCKER_NAME.conf
        cp $DOCKER_CERT_FILE    /etc/apache2/ssl.crt/$DOCKER_NAME.crt
        cp $DOCKER_KEY_FILE     /etc/apache2/ssl.key/$DOCKER_NAME.key
        cp $DOCKER_CHAIN_FILE   /etc/apache2/ssl.crt/ca-chain.crt
        cp $DOCKER_CHAIN_FILE   /etc/apache2/ssl.crt/ca.crt
        
        sed -i "s/___HOSTNAME___/$DOCKER_NAME/" /etc/apache2/sites-available/$DOCKER_NAME.conf
        sed -i "s/___DOCKER_SSL_PORT___/$DOCKER_SSL_PORT/" /etc/apache2/sites-available/$DOCKER_NAME.conf
        sed -i "s/___HOSTNAME_CERTFILE___/$DOCKER_NAME.crt/" /etc/apache2/sites-available/$DOCKER_NAME.conf
        sed -i "s/___HOSTNAME_KEYFILE___/$DOCKER_NAME.key/" /etc/apache2/sites-available/$DOCKER_NAME.conf
    fi    
    a2enmod ssl;
    a2ensite $DOCKER_NAME;
else
    a2dissite $DOCKER_NAME;
fi

if [ ! -z $DOCKER_WEB_SCRIPT ]; then
	if [ -f $DOCKER_WEB_SCRIPT -a -x $DOCKER_WEB_SCRIPT ]; then
		$DOCKER_WEB_SCRIPT
	fi
fi

if [ ! -z $DOCKER_NAME ]; then
	echo $HOSTNAME > $DOCKER_STATUS_PATH/$DOCKER_NAME;
fi

exec "$@"
