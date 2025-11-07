# syntax=docker/dockerfile:1
# Electron is not yet ready for 24.04
# https://github.com/cypress-io/cypress/issues/29521
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG APP_VERSION_FULL
ARG MINIFORGE3_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive

ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Miniforge3
# Inspired by https://github.com/conda-forge/miniforge-images/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        bzip2 \
        ca-certificates \
        curl && \
    pushd /var/cache/curl && \
    curl -sSL -C - -O "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE3_VERSION}/Miniforge3-${MINIFORGE3_VERSION}-$(uname)-$(uname -m).sh" && \
    /bin/bash Miniforge3-${MINIFORGE3_VERSION}-$(uname)-$(uname -m).sh -b -p "${CONDA_DIR}" && \
    conda clean --tarballs --index-cache --packages --yes && \
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
    find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
    apt-get remove -y --purge \
        curl && \
    apt-get autoremove -y --purge

# JupyterLab Desktop
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    --mount=type=cache,target=/mambaforge/pkgs,sharing=locked \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        dbus-x11 \
        curl \
        libasound2t64 \
        libatspi2.0-0 \
        libdrm2 \
        libgbm1 \
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libsecret-1-0 \
        libxss1 \
        libxtst6 \
        xdg-utils && \
    pushd /var/cache/curl && \
    curl -sSL -C - -o JupyterLab-Setup-${APP_VERSION_FULL}.deb "https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${APP_VERSION_FULL}/JupyterLab-Setup-Debian-x64.deb" && \
    dpkg -i JupyterLab-Setup-${APP_VERSION_FULL}.deb && \
    popd && \
    rm -r /opt/JupyterLab/chrome-sandbox && \
    . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    . "${CONDA_DIR}/etc/profile.d/mamba.sh" && \
    conda activate base && \
    mamba create -y --override-channels --channel=conda-forge --name=jlab_env \
        ipykernel \
        jupyterlab \
        nb_conda_kernels \
        pip && \
    mamba create -y --override-channels --channel=conda-forge --name=bioinformatics_env \
        joblib \
        lifelines \
        matplotlib \
        nltk \
        numpy \
        opencv \
        pandas \
        pillow \
        scikit-survival \
        scipy \
        seaborn \
        spacy \
        streamlit \
        tqdm && \
    apt-get remove -y --purge \
        curl && \
    apt-get autoremove -y --purge

ENV APP_CMD_PREFIX="export PATH=${CONDA_DIR}/bin:${PATH}"
ENV APP_SPECIAL="no"
ENV APP_CMD="jlab"
ENV PROCESS_NAME="jlab"
ENV APP_DATA_DIR_ARRAY=".jupyter"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    cp entrypoint/docker-entrypoint.sh / && \
    cp entrypoint/1-create-user.sh /docker-entrypoint.d && \
    cp entrypoint/3-symlink-appdata.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
