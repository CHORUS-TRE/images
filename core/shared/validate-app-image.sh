#!/bin/bash
# Validates a Chorus app image for common issues
# Usage: ./validate-app-image.sh <image-name>

set -e

IMAGE="$1"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image-name>"
    echo "Example: $0 myapp:latest"
    exit 1
fi

echo "================================================"
echo "Chorus App Image Validator"
echo "================================================"
echo "Image: $IMAGE"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: Image exists
echo "[CHECK 1/7] Checking if image exists..."
if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "  ❌ ERROR: Image not found. Build the image first."
    exit 1
fi
echo "  ✅ Image found"
echo ""

# Check 2: Base OS detection
echo "[CHECK 2/7] Detecting base OS..."
OS_INFO=$(docker run --rm "$IMAGE" cat /etc/os-release 2>/dev/null || echo "")
if echo "$OS_INFO" | grep -q "Ubuntu"; then
    UBUNTU_VERSION=$(echo "$OS_INFO" | grep VERSION_ID | cut -d'"' -f2)
    echo "  ✅ Ubuntu detected: $UBUNTU_VERSION"
    if [[ "$UBUNTU_VERSION" != "22.04" && "$UBUNTU_VERSION" != "24.04" ]]; then
        echo "  ⚠️  WARNING: Recommended versions are 22.04 or 24.04"
        ((WARNINGS++))
    fi
else
    echo "  ❌ ERROR: Not Ubuntu-based. Chorus requires Ubuntu 22.04 or 24.04"
    ((ERRORS++))
fi
echo ""

# Check 3: UID collision check (critical!)
echo "[CHECK 3/7] Checking for UID collisions (range 1001-9999)..."
PASSWD_CONTENT=$(docker run --rm "$IMAGE" cat /etc/passwd 2>/dev/null || echo "")
COLLISION_UIDS=$(echo "$PASSWD_CONTENT" | awk -F: '{print $3}' | grep -E '^[1-9][0-9]{3}$|^[1-9][0-9]{2}$' | sort -n)

if [ -n "$COLLISION_UIDS" ]; then
    echo "  ❌ ERROR: Found UIDs in Chorus user range (1001-9999):"
    echo "$PASSWD_CONTENT" | awk -F: '$3 >= 1001 && $3 <= 9999 {printf "    UID %s: %s\n", $3, $1}'
    echo "  ⚠️  These UIDs are reserved for Chorus users!"
    echo "  ⚠️  Collision impact: Audit trail confusion when users bypass libnss_wrapper"
    echo "  💡 Fix: Remove these users or change UIDs to ≥ 10000"
    ((ERRORS++))
else
    echo "  ✅ No UID collisions found in range 1001-9999"
fi
echo ""

# Check 4: libnss-wrapper presence (required for libc compatibility)
echo "[CHECK 4/7] Checking for libnss_wrapper..."
NSS_WRAPPER_FOUND=false
if docker run --rm "$IMAGE" test -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so 2>/dev/null; then
    echo "  ✅ libnss_wrapper found at /usr/lib/x86_64-linux-gnu/libnss_wrapper.so"
    NSS_WRAPPER_FOUND=true
elif docker run --rm "$IMAGE" test -f /usr/lib/libnss_wrapper.so 2>/dev/null; then
    echo "  ✅ libnss_wrapper found at /usr/lib/libnss_wrapper.so"
    NSS_WRAPPER_FOUND=true
else
    echo "  ⚠️  WARNING: libnss_wrapper.so not found in app image"
    echo "  ⚠️  This may cause libc version mismatch errors"
    echo "  💡 Fix: Install libnss-wrapper package or use chorus-utils.sh"
    ((WARNINGS++))
fi
echo ""

# Check 5: Entrypoint script
echo "[CHECK 5/7] Checking for docker-entrypoint.sh..."
if docker run --rm "$IMAGE" test -f /docker-entrypoint.sh 2>/dev/null; then
    echo "  ✅ /docker-entrypoint.sh found"

    # Check if it's executable
    if docker run --rm "$IMAGE" test -x /docker-entrypoint.sh 2>/dev/null; then
        echo "  ✅ Entrypoint is executable"
    else
        echo "  ⚠️  WARNING: Entrypoint is not executable"
        echo "  💡 Fix: RUN chmod +x /docker-entrypoint.sh"
        ((WARNINGS++))
    fi
else
    echo "  ❌ ERROR: /docker-entrypoint.sh not found"
    echo "  💡 Fix: Copy entrypoint script from core/entrypoint/"
    ((ERRORS++))
fi
echo ""

# Check 6: Required environment variables
echo "[CHECK 6/7] Checking environment variables..."
ENV_VARS=$(docker inspect "$IMAGE" -f '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null || echo "")

check_env_var() {
    local var_name="$1"
    local required="$2"

    if echo "$ENV_VARS" | grep -q "^${var_name}="; then
        local value=$(echo "$ENV_VARS" | grep "^${var_name}=" | cut -d'=' -f2-)
        echo "  ✅ $var_name is set: $value"
    else
        if [ "$required" = "true" ]; then
            echo "  ❌ ERROR: $var_name is not set"
            ((ERRORS++))
        else
            echo "  ⚠️  WARNING: $var_name is not set (optional)"
            ((WARNINGS++))
        fi
    fi
}

check_env_var "APP_NAME" "true"
check_env_var "APP_CMD" "true"
check_env_var "PROCESS_NAME" "true"
check_env_var "APP_DATA_DIR_ARRAY" "false"
echo ""

# Check 7: Test run with non-root user
echo "[CHECK 7/7] Testing execution as non-root user..."
if docker run --rm \
    --user 1234:1001 \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    -e CHORUS_USER=testuser \
    -e CHORUS_UID=1234 \
    -e CHORUS_GROUP=chorus \
    -e CHORUS_GID=1001 \
    -e APP_CMD="echo 'Chorus test successful'" \
    "$IMAGE" 2>&1 | grep -q "Chorus test successful"; then
    echo "  ✅ Image can run as non-root user with zero capabilities"
else
    echo "  ❌ ERROR: Image failed to run as non-root user"
    echo "  💡 This might indicate permission issues or missing dependencies"
    ((ERRORS++))
fi
echo ""

# Summary
echo "================================================"
echo "Validation Summary"
echo "================================================"
echo "Image: $IMAGE"
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ VALIDATION FAILED"
    echo "Please fix the errors above before deploying to Chorus"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  VALIDATION PASSED WITH WARNINGS"
    echo "The image should work but consider addressing the warnings"
    exit 0
else
    echo "✅ VALIDATION PASSED"
    echo "Image is compatible with Chorus!"
    exit 0
fi
