#!/bin/sh

set -e

APP_NAME="xpra-server"
APP_VERSION="6.3"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

# See: https://github.com/VirtualGL/virtualgl/releases
VIRTUALGL_VERSION=3.1.3
# See: https://xpra.org/dists/noble/main/binary-amd64/
XPRA_VERSION="${APP_VERSION}-r0"
XPRA_HTML5_VERSION="17-r2"

REGISTRY="${REGISTRY:=harbor.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:=apps}"
CACHE="${CACHE:=cache}"
BUILDER_NAME="docker-container"
TARGET_ARCH="${TARGET_ARCH:-linux/amd64}"

XPRA_KEYCLOAK_AUTH="False" # True or False
XPRA_KEYCLOAK_SERVER_URL=""
XPRA_KEYCLOAK_REALM_NAME=""
XPRA_KEYCLOAK_CLIENT_ID=""
XPRA_KEYCLOAK_CLIENT_SECRET_KEY=""
XPRA_KEYCLOAK_REDIRECT_URI=""
XPRA_KEYCLOAK_SCOPE="openid email profile group roles team"
XPRA_KEYCLOAK_CLAIM_FIELD="roles.groups"
XPRA_KEYCLOAK_AUTH_GROUPS="" #
XPRA_KEYCLOAK_AUTH_CONDITION="and"
XPRA_KEYCLOAK_GRANT_TYPE="authorization_code"

# Use `registry` to build and push
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

# Check if the builder exists
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

exec docker buildx build \
    --pull \
    --builder ${BUILDER_NAME} \
    --platform=${TARGET_ARCH} \
    -t ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION} \
    --build-arg "VIRTUALGL_VERSION=${VIRTUALGL_VERSION}" \
    --build-arg "XPRA_VERSION=${XPRA_VERSION}" \
    --build-arg "XPRA_HTML5_VERSION=${XPRA_HTML5_VERSION}" \
    --build-arg "XPRA_KEYCLOAK_AUTH=${XPRA_KEYCLOAK_AUTH}" \
    --build-arg "XPRA_KEYCLOAK_SERVER_URL=${XPRA_KEYCLOAK_SERVER_URL}" \
    --build-arg "XPRA_KEYCLOAK_REALM_NAME=${XPRA_KEYCLOAK_REALM_NAME}" \
    --build-arg "XPRA_KEYCLOAK_CLIENT_ID=${XPRA_KEYCLOAK_CLIENT_ID}" \
    --build-arg "XPRA_KEYCLOAK_CLIENT_SECRET_KEY=${XPRA_KEYCLOAK_CLIENT_SECRET_KEY}" \
    --build-arg "XPRA_KEYCLOAK_REDIRECT_URI=${XPRA_KEYCLOAK_REDIRECT_URI}" \
    --build-arg "XPRA_KEYCLOAK_SCOPE=${XPRA_KEYCLOAK_SCOPE}" \
    --build-arg "XPRA_KEYCLOAK_CLAIM_FIELD=${XPRA_KEYCLOAK_CLAIM_FIELD}" \
    --build-arg "XPRA_KEYCLOAK_AUTH_GROUPS=${XPRA_KEYCLOAK_AUTH_GROUPS}" \
    --build-arg "XPRA_KEYCLOAK_AUTH_CONDITION=${XPRA_KEYCLOAK_AUTH_CONDITION}" \
    --build-arg "XPRA_KEYCLOAK_GRANT_TYPE=${XPRA_KEYCLOAK_GRANT_TYPE}" \
    ${CACHE_FROM} \
    ${CACHE_TO} \
    --output=$OUTPUT \
    .
