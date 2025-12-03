#!/bin/sh
set -e

echo "========================================================================"
echo "                  Installing Chorus utilities                           "
echo "========================================================================"
echo ""

apt-get -qq update && \
apt-get install -qq --no-install-recommends -y curl ca-certificates gnupg libnss-wrapper && \

script_dir=$(dirname "$0")
"$script_dir"/install-vgl.sh "3.1.1-20240228"
"$script_dir"/install-utility-tools.sh "$@"
echo "===> Creating directory /docker-entrypoint.d"
mkdir /docker-entrypoint.d

# libnss_wrapper is installed from the app's Ubuntu version
# This ensures binary compatibility with the app's libc version
echo "===> Verifying libnss_wrapper installation"
if [ -f "/usr/lib/x86_64-linux-gnu/libnss_wrapper.so" ]; then
    echo "     libnss_wrapper.so found at /usr/lib/x86_64-linux-gnu/libnss_wrapper.so"
elif [ -f "/usr/lib/libnss_wrapper.so" ]; then
    echo "     libnss_wrapper.so found at /usr/lib/libnss_wrapper.so"
else
    echo "     WARNING: libnss_wrapper.so not found in expected locations"
    find /usr -name "libnss_wrapper.so" 2>/dev/null || true
fi

# Create NSS wrapper configuration for login shells
# This enables 'runuser -l' and 'su -' to resolve chorus users in debug mode
echo "===> Creating /etc/profile.d/chorus-nss.sh"
cat > /etc/profile.d/chorus-nss.sh << 'PROFILE_EOF'
# Chorus NSS wrapper configuration for user identity resolution
# Only set if not already set and auth files exist (container is running)
if [ -z "$LD_PRELOAD" ] && [ -f /home/.chorus-auth/passwd ]; then
    if [ -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    elif [ -f /usr/lib/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/libnss_wrapper.so
    fi
    export NSS_WRAPPER_PASSWD=/home/.chorus-auth/passwd
    export NSS_WRAPPER_GROUP=/home/.chorus-auth/group
fi
PROFILE_EOF
chmod 644 /etc/profile.d/chorus-nss.sh

# Also create a wrapper script for runuser that sets up NSS automatically
echo "===> Creating /usr/local/bin/csu (chorus switch user)"
cat > /usr/local/bin/csu << 'CSU_EOF'
#!/bin/bash
# Chorus Switch User - wrapper for runuser with NSS wrapper support
# Usage: csu <username> [command]
if [ -z "$1" ]; then
    echo "Usage: csu <username> [command]"
    exit 1
fi
TARGET_USER="$1"
shift
CMD="${@:-bash --norc -c 'exec bash'}"

# Set up NSS wrapper if not already set
if [ -z "$LD_PRELOAD" ] && [ -f /home/.chorus-auth/passwd ]; then
    if [ -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    elif [ -f /usr/lib/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/libnss_wrapper.so
    fi
    export NSS_WRAPPER_PASSWD=/home/.chorus-auth/passwd
    export NSS_WRAPPER_GROUP=/home/.chorus-auth/group
fi

# Execute runuser with login shell
# Note: Terminal warnings about "no job control" are harmless and expected in non-PTY environments
exec runuser -l "$TARGET_USER" -w DISPLAY,LD_PRELOAD,NSS_WRAPPER_PASSWD,NSS_WRAPPER_GROUP -c "$CMD"
CSU_EOF
chmod 755 /usr/local/bin/csu

apt-get -qq autoremove -y --purge
rm -rf /var/lib/apt/lists/*
