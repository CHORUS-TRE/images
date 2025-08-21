APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=$HOME/data/freesurfer_subjects

# Load the environment variables
if [ -s "/apps/ciclone/config/.env" ]; then
    . "/apps/ciclone/config/.env"
fi

# Create the freesurfer license file
echo -e "$CICLONE_FSF_LICENSE" > "$HOME/license.txt"

# Setup the FreeSurfer environment
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Setup the FSL environment
FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

LC_NUMERIC=en_GB.UTF-8
export LC_NUMERIC

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
