# Change the value for FSLDIR if you have 
# installed FSL into a different location
FSLDIR=/usr/local/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH

LC_NUMERIC=en_GB.UTF-8
export LC_NUMERIC

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"
