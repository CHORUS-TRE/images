#!/bin/sh

set -e

APP_NAME="sciterminal"
APP_VERSION="20241018"
PKG_REL="1"

VERSION="${APP_VERSION}-${PKG_REL}"

PLINK_VERSION="latest"
BCFTOOLS_VERSION="1.21"
SHAPEIT_VERSION="5.1.1"
IMPUTE_VERSION="1.2.0"

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
    --build-arg "PLINK_VERSION=${PLINK_VERSION}" \
    --build-arg "BCFTOOLS_VERSION=${BCFTOOLS_VERSION}" \
    --build-arg "SHAPEIT_VERSION=${SHAPEIT_VERSION}" \
    --build-arg "IMPUTE_VERSION=${IMPUTE_VERSION}" \
    --output=$OUTPUT \
    .
