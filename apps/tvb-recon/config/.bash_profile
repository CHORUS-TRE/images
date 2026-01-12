FREESURFER_APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${FREESURFER_APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=/apps/freesurfer/subjects

# Create a license file
if [ -s "/apps/freesurfer/config/.env" ]; then
    . "/apps/freesurfer/config/.env"
fi

echo -e "$FREESURFER_LICENSE" > "$HOME/license.txt"

. "$FREESURFER_HOME/SetUpFreeSurfer.sh"

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
