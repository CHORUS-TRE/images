APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=/apps/freesurfer/subjects

# Use runtime env var if set, otherwise source .env file (local dev)
if [ -z "$FREESURFER_LICENSE" ] && [ -s "/apps/freesurfer/config/.env" ]; then
    . "/apps/freesurfer/config/.env"
fi

echo -e "$FREESURFER_LICENSE" > "$HOME/license.txt"

. "$FREESURFER_HOME/SetUpFreeSurfer.sh"

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
