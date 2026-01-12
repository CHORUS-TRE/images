# Freesurfer environment setup
FREESURFER_APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${FREESURFER_APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=/apps/freesurfer/subjects

# Source the user-provided environment file if it exists.
# This file is persisted in the app's config directory.
if [ -s "/apps/tvb-recon/config/.env" ]; then
    . "/apps/tvb-recon/config/.env"
fi

echo -e "$FREESURFER_LICENSE" > "$HOME/license.txt"

. "$FREESURFER_HOME/SetUpFreeSurfer.sh"

# FSL environment setup
FSLDIR=/opt/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH

LC_NUMERIC=en_GB.UTF-8
export LC_NUMERIC

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
