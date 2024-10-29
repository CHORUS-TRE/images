APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt

# Create a license file
if [ -s "$HOME/config/.env" ]; then
    . "$HOME/config/.env"
fi

echo -e "$FREESURFER_LICENSE" > "$HOME/license.txt"

. "$FREESURFER_HOME/SetUpFreeSurfer.sh"

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
