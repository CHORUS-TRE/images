#!/bin/sh

set -e

# Build script for this app
# Usage: ./build.sh
#
# Environment variables:
#   REGISTRY    - Container registry (default: harbor.build.chorus-tre.local)
#   REPOSITORY  - Repository name (default: apps)
#   CACHE       - Cache repository name (default: cache)
#   TARGET_ARCH - Target architecture (default: linux/amd64)
#   OUTPUT      - Output type: docker, registry (default: docker)

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="$(basename "${APP_DIR}")"

# Parse labels file for build configuration
get_label() {
    value=$(grep "^${1}=" "${APP_DIR}/labels" 2>/dev/null | cut -d'=' -f2- || echo "")
    # Remove surrounding quotes if present
    echo "$value" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/"
}

# Extract build configuration from labels
APP_VERSION=$(get_label "ch.chorus-tre.build.app-version")
PKG_REL=$(get_label "ch.chorus-tre.build.pkg-rel")
CACHE_MODE=$(get_label "ch.chorus-tre.build.cache-mode")

# Validate required build labels
if [ -z "${APP_VERSION}" ]; then
    echo "Error: Missing 'ch.chorus-tre.build.app-version' in labels"
    exit 1
fi

if [ -z "${PKG_REL}" ]; then
    echo "Error: Missing 'ch.chorus-tre.build.pkg-rel' in labels"
    exit 1
fi

# Set defaults
CACHE_MODE="${CACHE_MODE:-max}"
VERSION="${APP_VERSION}-${PKG_REL}"

# Environment variable defaults
REGISTRY="${REGISTRY:-harbor.build.chorus-tre.local}"
REPOSITORY="${REPOSITORY:-apps}"
CACHE="${CACHE:-cache}"
BUILDER_NAME="docker-container"
TARGET_ARCH="${TARGET_ARCH:-linux/amd64}"
OUTPUT_TYPE="type=${OUTPUT:-docker}"

TAG="${REGISTRY}/${CACHE}/${APP_NAME}-${CACHE}"

echo "Building ${APP_NAME} version ${VERSION}"
echo "  Registry: ${REGISTRY}"
echo "  Repository: ${REPOSITORY}"
echo "  Architecture: ${TARGET_ARCH}"
echo "  Cache mode: ${CACHE_MODE}"

# Configure cache based on output type
if [ "$OUTPUT_TYPE" = "type=registry" ]; then
    CACHE_FROM="\
        --cache-from=type=registry,ref=${TAG}:${VERSION} \
        --cache-from=type=registry,ref=${TAG}:latest"
    CACHE_TO="\
        --cache-to=type=registry,ref=${TAG}:${VERSION},mode=${CACHE_MODE},image-manifest=true \
        --cache-to=type=registry,ref=${TAG}:latest,mode=${CACHE_MODE},image-manifest=true"
else
    mkdir -p /tmp/.buildx-cache
    CACHE_FROM="--cache-from=type=local,src=/tmp/.buildx-cache"
    CACHE_TO="--cache-to=type=local,dest=/tmp/.buildx-cache"
fi

# Check if the builder exists
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Copy core scripts to app directory
cp -r "${APP_DIR}/../../core" "${APP_DIR}/core"
trap "rm -rf ${APP_DIR}/core" EXIT

# Convert logo.png to base64 if it exists
ICON_BASE64=""
if [ -f "${APP_DIR}/logo.png" ]; then
    echo "  Found logo.png, converting to base64..."
    ICON_BASE64="data:image/png;base64,$(base64 < "${APP_DIR}/logo.png" | tr -d '\n')"
fi

# Extract extra build args from labels (ch.chorus-tre.build.arg.*)
# and collect all labels for the image
BUILD_ARGS=""
LABELS=""

# Find base labels file and kiosk-specific labels in apps/ folder
LABELS_FILES="${APP_DIR}/labels"
if [ -d "${APP_DIR}/apps" ]; then
    LABELS_FILES="${LABELS_FILES} $(find "${APP_DIR}/apps" -maxdepth 1 -type f | sort)"
fi
echo "  Processing labels files: $(echo ${LABELS_FILES} | xargs -n1 basename | tr '\n' ' ')"

# Process each labels file
for LABELS_FILE in ${LABELS_FILES}; do
    # Extract kiosk name from filename if in apps/ folder
    LABELS_BASENAME=$(basename "${LABELS_FILE}")
    KIOSK_NAME=""
    case "${LABELS_FILE}" in
        */apps/*)
            KIOSK_NAME="${LABELS_BASENAME}"
            ;;
    esac

    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [ -z "$key" ] && continue
        # Remove surrounding quotes from value if present
        value=$(echo "$value" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
        case "$key" in
            ch.chorus-tre.build.arg.*)
                ARG_NAME="${key#ch.chorus-tre.build.arg.}"
                BUILD_ARGS="${BUILD_ARGS} --build-arg \"${ARG_NAME}=${value}\""
                echo "  Build arg: ${ARG_NAME}=${value}"
                ;;
            ch.chorus-tre.build.*)
                # Skip build metadata labels (they are not image labels)
                ;;
            ch.chorus-tre.app.icon)
                # Use logo.png if available, otherwise skip this label
                if [ -n "${ICON_BASE64}" ]; then
                    LABELS="${LABELS} --label \"ch.chorus-tre.app.icon=${ICON_BASE64}\""
                fi
                ;;
            ch.chorus-tre.app.kiosk-config-url.*)
                # For kiosk-config-url labels, inject kiosk name from filename
                if [ -n "${KIOSK_NAME}" ]; then
                    # Transform: ch.chorus-tre.app.kiosk-config-url.X -> ch.chorus-tre.app.kiosk-config-url.KIOSK_NAME.X
                    SUFFIX="${key#ch.chorus-tre.app.kiosk-config-url.}"
                    NEW_KEY="ch.chorus-tre.app.kiosk-config-url.${KIOSK_NAME}.${SUFFIX}"
                    LABELS="${LABELS} --label \"${NEW_KEY}=${value}\""
                else
                    # Base labels file - use key as-is (shouldn't happen normally)
                    LABELS="${LABELS} --label \"${key}=${value}\""
                fi
                ;;
            *)
                # Add all other labels to the image
                LABELS="${LABELS} --label \"${key}=${value}\""
                ;;
        esac
    done < "${LABELS_FILE}"
done

# Build the image
eval docker buildx build \
    --pull \
    --builder "${BUILDER_NAME}" \
    --platform="${TARGET_ARCH}" \
    -t "${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION}" \
    ${LABELS} \
    --label "org.opencontainers.image.version=${VERSION}" \
    --label "ch.chorus-tre.app.name=${APP_NAME}" \
    --label "ch.chorus-tre.app.version=${APP_VERSION}" \
    --label "ch.chorus-tre.image.name=${APP_NAME}" \
    --label "ch.chorus-tre.image.tag=${VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    ${BUILD_ARGS} \
    ${CACHE_FROM} \
    ${CACHE_TO} \
    --output="${OUTPUT_TYPE}" \
    "${APP_DIR}"

BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
    echo ""
    echo "Failed to build ${APP_NAME}"
    exit 1
fi

echo ""
echo "Successfully built ${REGISTRY}/${REPOSITORY}/${APP_NAME}:${VERSION}"
