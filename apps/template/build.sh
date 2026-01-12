#!/bin/sh
set -e

# --- Configuration ---
# The name of the application. This should match the directory name.
APP_NAME="template"
# The semantic version of the application being packaged.
APP_VERSION="1.0.0"
# The package release number. Increment this for any change to the Dockerfile
# or build script that doesn't change the application version itself.
# Reset to 1 when APP_VERSION is incremented.
PKG_REL="1"

# --- Versioning ---
# Combines the app version and package release for the final image tag.
VERSION="${APP_VERSION}-${PKG_REL}"

# --- Docker Build Configuration ---
# These variables can be overridden by the CI/CD environment.
REGISTRY="${REGISTRY:=harbor.build.chorus-tre.ch}"
REPOSITORY="${REPOSITORY:=chorus}"
CACHE="${CACHE:=buildcache}"
BUILDER_NAME="docker-container"
TARGET_ARCH="${TARGET_ARCH:-linux/amd64}"

# Defines the output of the build.
# 'type=docker' builds the image into the local Docker daemon.
# 'type=registry' pushes the image directly to the registry.
OUTPUT="type=${OUTPUT:-docker}"

# --- Caching Configuration ---
# Defines the remote cache image reference.
CACHE_IMAGE_REF=${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}

# Configure cache sources and destinations based on the OUTPUT type.
if [ "$OUTPUT" = "type=registry" ]; then
    CACHE_FROM="\
        --cache-from=type=registry,ref=${CACHE_IMAGE_REF}:${VERSION} \
        --cache-from=type=registry,ref=${CACHE_IMAGE_REF}:latest"
    CACHE_TO="\
        --cache-to=type=registry,ref=${CACHE_IMAGE_REF}:${VERSION},mode=max,image-manifest=true \
        --cache-to=type=registry,ref=${CACHE_IMAGE_REF}:latest,mode=max,image-manifest=true"
else
    # For local builds, use a local cache directory.
    mkdir -p /tmp/.buildx-cache
    CACHE_FROM="--cache-from=type=local,src=/tmp/.buildx-cache"
    CACHE_TO="--cache-to=type=local,dest=/tmp/.buildx-cache"
fi

# --- Main Build Script ---
# Ensure a 'docker-container' builder is available.
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    echo "Creating docker-container builder..."
    docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Copy the 'core' scripts into the current directory for the build context.
# These scripts are essential for Chorus integration.
cp -r ../../core ./core

# Set up a trap to automatically remove the 'core' directory on script exit.
trap "rm -rf ./core" EXIT

echo "--- Building Docker image: ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} ---"

# Execute the build using Docker Buildx.
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
