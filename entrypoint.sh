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

for entrypoint in /entrypoint.d/*.sh
do
    if [ -f $entrypoint -a -x $entrypoint ]
    then
        $entrypoint
    fi
done

exec "$@"