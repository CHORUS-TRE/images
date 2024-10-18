#!/bin/sh

set -e

APP_NAME="wezterm"
APP_VERSION="20240203"
PKG_REL="1"

VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.
cp -r ../../core ./core
trap "rm -rf core" EXIT

docker buildx build \
    --pull \
    -t ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --output=$OUTPUT \
    .
