#!/bin/sh

APP_NAME="i2b2"
APP_VERSION="1.8.1a.0001"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

docker buildx build \
    --pull \
    -t ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --output=$OUTPUT \
    .
