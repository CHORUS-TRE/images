# syntax=docker/dockerfile:1

# BUILDER STAGE
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS builder
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG MINIFORGE3_VERSION=24.9.0-0
ARG FREESURFER_VERSION=7.2.0
ARG FSL_VERSION=6.0.7.17
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Install build dependencies, Miniforge, FSL, FreeSurfer, and MRtrix3
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    # Install build dependencies
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libgl1 \
        libglx0 \
        libsm6 \
        libxext6 \
        libxrender1 && \
    # Download and install Miniforge
    pushd /tmp && \
    curl -sSL -C - -O "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE3_VERSION}/Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh" && \
    /bin/bash Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh -b -p "${CONDA_DIR}" && \
    popd && \
    # Activate conda and create the runtime environment
    . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    conda activate base && \
    mamba create -y --override-channels --channel=conda-forge --channel=mrtrix3 --name=tvb_recon_env \
        python=3.12 \
        pegasus-wms \
        htcondor \
        mrtrix3 && \
    # Install FSL
    curl -sSL https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -o /tmp/fslinstaller.py && \
    sed -i -E "s/(printmsg\(([^,]+, )?end='(\\\\r)?')/# SILENCE \\1/g" /tmp/fslinstaller.py && \
    python3 /tmp/fslinstaller.py \
        -d /opt/fsl \
        -V ${FSL_VERSION} \
        --skip_registration && \
    # Install FreeSurfer
    pushd /tmp && \
    curl -sSL -C - -o freesurfer.tar.gz "https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer-linux-centos7_x86_64-${FREESURFER_VERSION}.tar.gz" && \
    tar -xzf freesurfer.tar.gz -C /opt && \
    popd && \
    # Clean up temporary files and caches
    rm -rf /tmp/* && \
    conda clean --all --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download TVB-recon source code
RUN git clone --depth 1 https://github.com/the-virtual-brain/tvb-recon.git /opt/tvb-recon

# Install TVB-recon and its python dependencies from setup.py
RUN . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    conda activate tvb_recon_env && \
    pip install --no-cache-dir /opt/tvb-recon/ && \
    conda clean --all --yes


# FINAL STAGE
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}
ARG DEBIAN_FRONTEND=noninteractive

# Copy only the required conda environment from the builder
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}
COPY --from=builder ${CONDA_DIR}/envs/tvb_recon_env ${CONDA_DIR}/envs/tvb_recon_env

# Copy FSL, FreeSurfer, and TVB-recon from the builder
COPY --from=builder /opt/fsl /opt/fsl
COPY --from=builder /opt/freesurfer /opt/freesurfer
COPY --from=builder /opt/tvb-recon /opt/tvb-recon

# Set up environment for TVB-recon
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="tvb-recon"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

# Install runtime dependencies and Chorus scripts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    libgl1 \
    libglx0 \
    libsm6 \
    libxext6 \
    libxrender1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/ /apps/${APP_NAME}/config/

RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/1-copy-config.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
