#!/bin/sh

set -e

APP_NAME="mrtrix3"
APP_VERSION=3.0.4
PKG_REL="1"

# https://conda-forge.org/miniforge/
# https://github.com/conda-forge/miniforge/releases
MINIFORGE3_VERSION="24.7.1-2"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

cp -r ../../core ./core
trap "rm -rf ./core" EXIT

docker buildx build \
    --pull \
    -t ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --build-arg "MINIFORGE3_VERSION=${MINIFORGE3_VERSION}" \
    --output=$OUTPUT \
    .
