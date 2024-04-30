#!/bin/sh

VERSION=0.0.1
APP_NAME="xpra-server"
APP_VERSION="latest"
REGISTRY="registry.build.chorus-tre.ch"

docker build -t ${REGISTRY}/${APP_NAME}:${VERSION} --build-arg APP_NAME=${APP_NAME} --build-arg APP_VERSION=${APP_VERSION} .
docker tag ${REGISTRY}/${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:latest
docker push ${REGISTRY}/${APP_NAME}:latest
docker push ${REGISTRY}/${APP_NAME}:$VERSION
