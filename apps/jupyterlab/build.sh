#!/bin/sh

set -e

APP_NAME="jupyterlab"
# https://github.com/jupyterlab/jupyterlab-desktop/releases
APP_VERSION="4.2.5"
APP_VERSION_FULL="${APP_VERSION}-1"
PKG_REL="1"

# https://conda-forge.org/miniforge/
# https://github.com/conda-forge/miniforge/releases
MINIFORGE3_VERSION="24.7.1-0"

VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

cp -r ../../core ./core
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
    --build-arg "MINIFORGE3_VERSION=${MINIFORGE3_VERSION}" \
    --output=$OUTPUT \
    .
