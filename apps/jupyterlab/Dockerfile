# syntax=docker/dockerfile:1
FROM ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
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
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        dbus-x11 \
        curl \
        libasound2 \
        libatspi2.0-0 \
        libdrm2 \
        libgbm1 \
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libsecret-1-0 \
        libxss1 \
        libxtst6 \
        tini \
        xdg-utils && \
    pushd /var/cache/curl && \
    curl -sSL -C - -o JupyterLab-Setup-${APP_VERSION}.deb "https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${APP_VERSION}/JupyterLab-Setup-Debian-x64.deb" && \
    dpkg -i JupyterLab-Setup-${APP_VERSION}.deb && \
    popd && \
    rm -r /opt/JupyterLab/chrome-sandbox && \
    source "${CONDA_DIR}/etc/profile.d/conda.sh" && \
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

ENV APP_SPECIAL="no"
ENV APP_CMD="jlab --no-sandbox"
ENV APP_CMD_PREFIX="export PATH=${CONDA_DIR}/bin:${PATH}"
ENV PROCESS_NAME="jlab"
ENV APP_DATA_DIR_ARRAY=".jupyter"
ENV DATA_DIR_ARRAY=""

COPY . .

ENTRYPOINT ["tini", "--", "./docker-entrypoint.sh"]
