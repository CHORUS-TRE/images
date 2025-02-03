#!/bin/sh

set -e

APP_NAME="jupyterlab"
# https://github.com/jupyterlab/jupyterlab-desktop/releases
APP_VERSION="4.2.5"
APP_VERSION_FULL="${APP_VERSION}-1"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

# https://conda-forge.org/miniforge/
# https://github.com/conda-forge/miniforge/releases
MINIFORGE3_VERSION="24.9.0-0"

REGISTRY="${REGISTRY:=harbor.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"
CACHE="${CACHE:=cache}"
BUILDER_NAME="docker-container"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

if [ "$OUTPUT" = "type=registry" ]; then
    CACHE_FROM="\
        --cache-from=type=registry,ref=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}:${VERSION} \
        --cache-from=type=registry,ref=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}:latest"

    CACHE_TO="\
        --cache-to=type=registry,ref=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}:${VERSION},mode=max,image-manifest=true \
        --cache-to=type=registry,ref=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}:latest,mode=max,image-manifest=true"
else
    mkdir -p /tmp/.buildx-cache  # Ensure cache directory exists
    CACHE_FROM="--cache-from=type=local,src=/tmp/.buildx-cache"
    CACHE_TO="--cache-to=type=local,dest=/tmp/.buildx-cache"
fi

# Check if the builder exists
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

cp -r ../../core ./core
trap "rm -rf ./core" EXIT

docker buildx build \
    --pull \
    --builder ${BUILDER_NAME} \
    -t ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_VERSION_FULL=${APP_VERSION_FULL}" \
    --build-arg "MINIFORGE3_VERSION=${MINIFORGE3_VERSION}" \
    --output=$OUTPUT \
    ${CACHE_FROM} \
    ${CACHE_TO} \
    .
