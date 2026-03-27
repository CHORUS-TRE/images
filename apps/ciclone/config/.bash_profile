APP_VERSION=$(ls /usr/local/freesurfer/)

export FREESURFER_HOME=/usr/local/freesurfer/${APP_VERSION}
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=$HOME/data/freesurfer_subjects

# License is injected by the workbench-operator via FREESURFER_LICENSE env var
if [ -n "$FREESURFER_LICENSE" ]; then
    echo "$FREESURFER_LICENSE" > "$HOME/license.txt"
fi

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
