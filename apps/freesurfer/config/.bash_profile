APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt

# Create a license file
[[ -s "$HOME/config/.env" ]] && source "$HOME/config/.env"
echo -e $FREESURFER_LICENSE > $HOME/license.txt

source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"
