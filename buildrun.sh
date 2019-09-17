#!/bin/bash
set -e

IMAGE_TAG=qemu-arm
CONTAINER_NAME=qemu-arm

docker build -t $IMAGE_TAG .
docker run \
    --rm \
    -ti \
    --name $CONTAINER_NAME \
    $IMAGE_TAG \
    $@
