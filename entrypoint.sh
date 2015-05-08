#!/bin/bash

for entrypoint in /entrypoint.d/*.sh
do
    if [ -f $entrypoint -a -x $entrypoint ]
    then
        $entrypoint
    fi
done

exec "$@"