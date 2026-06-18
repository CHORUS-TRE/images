export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export FS_LICENSE=$HOME/license.txt

# License is injected by the workbench-operator via FREESURFER_LICENSE env var
if [ -n "$FREESURFER_LICENSE" ]; then
    echo "$FREESURFER_LICENSE" > "$HOME/license.txt"
fi

# Load the default .profile
if [ -s "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
