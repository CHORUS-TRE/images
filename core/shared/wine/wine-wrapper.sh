#!/bin/bash
# Wine wrapper script - disables X11 SHM to fix Xpra compatibility
# The MIT-SHM extension causes crashes in containerized Xpra environments
# 
# Solution: Use LD_PRELOAD to intercept XShmQueryExtension and disable SHM

# Unset LD_PRELOAD to avoid 32-bit Wine process conflicts with 64-bit libnss_wrapper
unset LD_PRELOAD

# Suppress Wine debug output
export WINEDEBUG="-all"

# Disable Wine menu builder (not needed in container)
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# Disable MIT-SHM for various toolkits and libraries
export QT_X11_NO_MITSHM=1
export _X11_NO_MITSHM=1

# Force software rendering
export LIBGL_ALWAYS_SOFTWARE=1

# MESA: disable shader cache
export MESA_SHADER_CACHE_DISABLE=1

WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

# Save current display
SAVED_DISPLAY="$DISPLAY"
unset DISPLAY

# Kill any existing wineserver to ensure clean state
wineserver -k 2>/dev/null || true

# Initialize Wine prefix if needed (headless, no GUI)
if [ ! -f "$WINEPREFIX/user.reg" ]; then
    echo "Initializing Wine prefix at $WINEPREFIX..."
    wineboot --init 2>/dev/null || true
    wineserver --wait 2>/dev/null || true
    echo "Wine prefix initialized"
fi

# Configure X11 driver settings using Wine's regedit
echo "Configuring Wine X11 driver via regedit..."

REG_FILE=$(mktemp --suffix=.reg)
cat > "$REG_FILE" << 'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXShm"="N"
"UseXVidMode"="N"
EOF

wine regedit "$REG_FILE" 2>/dev/null || true
wineserver --wait 2>/dev/null || true
rm -f "$REG_FILE"

# Verify the setting
if grep -q '"UseXShm"="N"' "$WINEPREFIX/user.reg" 2>/dev/null; then
    echo "Wine X11 SHM disabled in registry"
else
    echo "Warning: UseXShm setting may not have been applied"
fi

# Force wineserver to completely stop
wineserver -k 2>/dev/null || true
sleep 0.5

# Restore display
export DISPLAY="$SAVED_DISPLAY"

echo "Starting Wine application..."

# Use the pre-built MIT-SHM disable wrapper
# This intercepts all XShm* functions to prevent Wine from using MIT-SHM
# The library is installed in standard multilib paths:
#   /usr/lib/x86_64-linux-gnu/noshm.so (64-bit)
#   /usr/lib/i386-linux-gnu/noshm.so (32-bit)
SHM_WRAPPER_64="/usr/lib/x86_64-linux-gnu/noshm.so"
SHM_WRAPPER_32="/usr/lib/i386-linux-gnu/noshm.so"

if [ -f "$SHM_WRAPPER_64" ] && [ -f "$SHM_WRAPPER_32" ]; then
    echo "Using MIT-SHM disable wrapper (32-bit and 64-bit)"
    # Both paths - dynamic linker will use the correct one for each process architecture
    exec env LD_PRELOAD="$SHM_WRAPPER_64 $SHM_WRAPPER_32" wine "$@"
elif [ -f "$SHM_WRAPPER_64" ]; then
    echo "Using MIT-SHM disable wrapper (64-bit only)"
    exec env LD_PRELOAD="$SHM_WRAPPER_64" wine "$@"
else
    exec wine "$@"
fi
