#!/bin/sh

set -e

APP_NAME="itksnap"
# See: https://sourceforge.net/projects/itk-snap/files/itk-snap/
APP_VERSION="4.2.0"
APP_VERSION_FULL="${APP_VERSION}-20240422"
PKG_REL="1"

VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

cp -rp ../../core .
trap "rm -rf core" EXIT

docker buildx build \
    --pull \
    -t ${REGISTRY}/${APP_NAME} \
    -t ${REGISTRY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_VERSION_FULL=${APP_VERSION_FULL}" \
    --output=$OUTPUT \
    .
