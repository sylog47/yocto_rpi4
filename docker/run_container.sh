#!/bin/sh

USER_NAME=yocto_rpi
VERSION=v1
CONTAINER_HOME=/home/${USER_NAME}
CONTAINER_NAME_BASE=yocto_rpi-sdk
CONTAINER_NAME=${CONTAINER_NAME_BASE}-${VERSION}
IMAGE_NAME=${CONTAINER_NAME_BASE}:${VERSION}
WORK_DIR_NAME=kernel

docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
docker run -it --privileged -e "TZ=Asia/Seoul" \
    -e "TERM=xterm-256color" \
    --network=host \
    -v /etc/localtime:/etc/localtime \
    --device="/dev/sdc1:/dev/sdc1" \
    --device="/dev/sdc2:/dev/sdc2" \
    --volume="$PWD/..:/${CONTAINER_HOME}/${WORK_DIR_NAME}" \
    -u ${USER_NAME} --name ${CONTAINER_NAME} ${IMAGE_NAME}
