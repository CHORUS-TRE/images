APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=/apps/freesurfer/subjects

# License is injected by the workbench-operator via FREESURFER_LICENSE env var
if [ -n "$FREESURFER_LICENSE" ]; then
    echo "$FREESURFER_LICENSE" > "$HOME/license.txt"
fi

. "$FREESURFER_HOME/SetUpFreeSurfer.sh"

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
