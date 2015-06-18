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

DOCKER_STATUS_PATH=/var/local/docker-data/containers-status
mkdir -p $DOCKER_STATUS_PATH
if [ -z ${DOCKER_WAIT_FOR+x} ]; then
	echo "Starting $DOCKER_NAME...";
else
	while : ; do
		[[ -f "$DOCKER_STATUS_PATH/$DOCKER_WAIT_FOR" ]] && break
		#echo "."
		sleep 1
	done
fi
chmod -R a+rw $DOCKER_STATUS_PATH

for entrypoint in /entrypoint.d/*.sh
do
    if [ -f $entrypoint -a -x $entrypoint ]
    then
        $entrypoint
    fi
done

if [ ! -z $DOCKER_NAME ]; then
	echo $HOSTNAME > $DOCKER_STATUS_PATH/$DOCKER_NAME
fi


exec "$@"