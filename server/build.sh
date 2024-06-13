#!/bin/sh

VERSION=0.0.1
APP_NAME="xpra"
APP_VERSION="latest"
REGISTRY="registry.build.chorus-tre.ch"

XPRA_VERSION="master"
XPRA_KEYCLOAK_AUTH="False" # True or False
XPRA_KEYCLOAK_SERVER_URL=""
XPRA_KEYCLOAK_REALM_NAME=""
XPRA_KEYCLOAK_CLIENT_ID=""
XPRA_KEYCLOAK_CLIENT_SECRET_KEY=""
XPRA_KEYCLOAK_REDIRECT_URI=""
XPRA_KEYCLOAK_SCOPE="openid email profile group roles team"
XPRA_KEYCLOAK_GROUPS_CLAIM="roles.groups"
XPRA_KEYCLOAK_AUTH_GROUPS="" #
XPRA_KEYCLOAK_AUTH_CONDITION="and"
XPRA_KEYCLOAK_GRANT_TYPE="authorization_code"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

# to build locally \
#-t ${APP_NAME} \
# to push to registry \
#-t ${REGISTRY}/${APP_NAME} \
#-t ${REGISTRY}/${APP_NAME}:${VERSION} \
    
exec docker buildx build \
	--pull \
    -f "Dockerfile.ubuntu-main" \
    -t ${APP_NAME} \
	--label "APP_NAME=${APP_NAME}" \
	--label "APP_VERSION=${APP_VERSION}" \
	--build-arg "APP_NAME=${APP_NAME}" \
	--build-arg "APP_VERSION=${APP_VERSION}" \
    --build-arg "XPRA_VERSION=${XPRA_VERSION}" \
    --build-arg "XPRA_KEYCLOAK_AUTH=${XPRA_KEYCLOAK_AUTH}" \
    --build-arg "XPRA_KEYCLOAK_SERVER_URL=${XPRA_KEYCLOAK_SERVER_URL}" \
    --build-arg "XPRA_KEYCLOAK_REALM_NAME=${XPRA_KEYCLOAK_REALM_NAME}" \
    --build-arg "XPRA_KEYCLOAK_CLIENT_ID=${XPRA_KEYCLOAK_CLIENT_ID}" \
    --build-arg "XPRA_KEYCLOAK_CLIENT_SECRET_KEY=${XPRA_KEYCLOAK_CLIENT_SECRET_KEY}" \
    --build-arg "XPRA_KEYCLOAK_REDIRECT_URI=${XPRA_KEYCLOAK_REDIRECT_URI}" \
    --build-arg "XPRA_KEYCLOAK_SCOPE=${XPRA_KEYCLOAK_SCOPE}" \
    --build-arg "XPRA_KEYCLOAK_GROUPS_CLAIM=${XPRA_KEYCLOAK_GROUPS_CLAIM}" \
    --build-arg "XPRA_KEYCLOAK_AUTH_GROUPS=${XPRA_KEYCLOAK_AUTH_GROUPS}" \
    --build-arg "XPRA_KEYCLOAK_AUTH_CONDITION=${XPRA_KEYCLOAK_AUTH_CONDITION}" \
    --build-arg "XPRA_KEYCLOAK_GRANT_TYPE=${XPRA_KEYCLOAK_GRANT_TYPE}" \
	--output=$OUTPUT \
	.
