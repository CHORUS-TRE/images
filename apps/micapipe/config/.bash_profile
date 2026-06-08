# micapipe — Chorus runtime environment.
# Sourced by the login shell that launches the terminal; every export below is
# inherited by the kitty terminal and the shells the user opens inside it.

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8

# --- FreeSurfer 7.3.2 ------------------------------------------------------
# The license is injected by the workbench-operator via the FREESURFER_LICENSE
# env var (same `freesurfer` secret as the FreeSurfer / CiCLONE apps) and written
# to $HOME/license.txt at startup. Pass it to micapipe with `-fs_licence $FS_LICENSE`.
export FREESURFER_HOME=/opt/freesurfer-7.3.2
export FS_LICENSE=$HOME/license.txt
export SUBJECTS_DIR=$HOME
if [ -n "$FREESURFER_LICENSE" ]; then
    echo "$FREESURFER_LICENSE" > "$HOME/license.txt"
fi
source "$FREESURFER_HOME/SetUpFreeSurfer.sh" >/dev/null 2>&1 || true

# --- FSL 6.0.2 -------------------------------------------------------------
export FSLDIR=/opt/fsl-6.0.2
export FSLOUTPUTTYPE=NIFTI_GZ
source "$FSLDIR/etc/fslconf/fsl.sh" 2>/dev/null || true
export PATH=$FSLDIR/bin:$PATH

# --- ANTs / AFNI / c3d / dcm2niix -----------------------------------------
export ANTSPATH=/opt/ants-2.4.1/bin
export AFNI_PLUGINPATH=/opt/afni-latest
export PATH=/opt/afni-latest:/opt/ants-2.4.1/bin:/opt/c3d-1.0.0-Linux-x86_64/bin:/opt/dcm2niix-v1.0.20190902/bin:$PATH

# --- FIX (binary not bundled — see README.md) ------------------------------
export FIXPATH=/opt/fix1.068
export PATH=/opt/fix1.068:$PATH

# --- micapipe --------------------------------------------------------------
export MICAPIPE=/opt/micapipe
export PROC="container_micapipe-v0.2.3"
export PATH=/opt/micapipe:/opt/micapipe/functions:$PATH

# --- Python env (micapipe deps + MRtrix3 3.0.1) ----------------------------
# Activated last so the env's python takes precedence on PATH.
if [ -f /opt/miniconda-22.11.1/etc/profile.d/conda.sh ]; then
    source /opt/miniconda-22.11.1/etc/profile.d/conda.sh
    conda activate micapipe 2>/dev/null || true
fi

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
