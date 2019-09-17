#!/bin/bash
set -e

CONTAINER_NAME=qemu-arm

if [[ -z $@ ]]; then
    cmd=bash
else
    cmd=$@
fi

docker exec -ti $CONTAINER_NAME ${cmd}
