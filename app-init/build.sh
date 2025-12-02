#!/bin/sh

set -e

# app-init
IMAGE_NAME="app-init"
APP_VERSION="0.0.2"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=harbor.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"
CACHE="${CACHE:=cache}"
BUILDER_NAME="docker-container"
TARGET_ARCH="${TARGET_ARCH:-linux/amd64}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

TAG=${REGISTRY}/${CACHE}/${IMAGE_NAME}-${CACHE}

# if registry use registry cache otherwise local cache
if [ "$OUTPUT" = "type=registry" ]; then
    CACHE_FROM="\
        --cache-from=type=registry,ref=${TAG}:${VERSION} \
        --cache-from=type=registry,ref=${TAG}:latest"
    CACHE_TO="\
        --cache-to=type=registry,ref=${TAG}:${VERSION},mode=max,image-manifest=true \
        --cache-to=type=registry,ref=${TAG}:latest,mode=max,image-manifest=true"
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

# Copy core scripts needed for init container
cp -r ../core ./core
trap "rm -rf ./core" EXIT

docker buildx build \
    --pull \
    --builder ${BUILDER_NAME} \
    --platform=${TARGET_ARCH} \
    -t ${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${VERSION} \
    --label "IMAGE_NAME=${IMAGE_NAME}" \
    --label "VERSION=${VERSION}" \
    --output=$OUTPUT \
    ${CACHE_FROM} \
    ${CACHE_TO} \
    .
