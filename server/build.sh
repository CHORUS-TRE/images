#!/bin/sh

APP_NAME="xpra-server"
APP_VERSION="6.1.3"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

# See: https://github.com/VirtualGL/virtualgl/releases
VIRTUALGL_VERSION=3.1.1
# See: https://xpra.org/dists/noble/main/binary-amd64/
XPRA_VERSION="${APP_VERSION}-r0"
XPRA_HTML5_VERSION="16.1-r0"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"

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

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

exec docker buildx build \
    --pull \
    -t ${REGISTRY}/${APP_NAME} \
    -t ${REGISTRY}/${APP_NAME}:${VERSION} \
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
    --output=$OUTPUT \
    .
