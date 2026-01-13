#!/bin/sh
set -e

# --- Configuration ---
APP_NAME="tvb-recon"
APP_VERSION="1.0.0"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

# --- Docker Configuration ---
REGISTRY="${REGISTRY:=harbor.build.chorus-tre.ch}"
REPOSITORY="${REPOSITORY:=apps}"
CACHE="${CACHE:=cache}"
BUILDER_NAME="docker-container"
TARGET_ARCH="${TARGET_ARCH:-linux/amd64}"

# Use `registry` to build and push, or `docker` for local builds
OUTPUT="type=${OUTPUT:-docker}"

TAG=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}

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

# --- Main Script ---
# Check if the builder exists
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Copy core scripts into the build context
cp -r ../../core ./core
# Cleanup core directory on exit
trap "rm -rf ./core" EXIT

echo "--- Building Docker image ---"
docker buildx build \
    --pull \
    --builder ${BUILDER_NAME} \
    --platform=${TARGET_ARCH} \
    -t "${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION}" \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    --output=$OUTPUT \
    ${CACHE_FROM} \
    ${CACHE_TO} \
    .

echo "--- Build complete ---"
echo "Image: ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION}"
