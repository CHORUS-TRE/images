# syntax=docker/dockerfile:1

# BUILDER STAGE
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS builder
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG MINIFORGE3_VERSION=24.9.0-0
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Install build dependencies and Miniforge
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libgl1-mesa-glx \
        libsm6 \
        libxext6 \
        libxrender1 && \
    # Download and install Miniforge
    pushd /tmp && \
    curl -sSL -C - -O "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE3_VERSION}/Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh" && \
    /bin/bash Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh -b -p "${CONDA_DIR}" && \
    popd && \
    rm -rf /tmp/Miniforge3* && \
    # Clean conda cache
    conda clean --all --yes

# Create tvb-recon environment and install dependencies
RUN . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    conda activate base && \
    mamba create -y --override-channels --channel=conda-forge --name=tvb_recon_env \
        python=3.10 \
        pegasus-wms.condor \
        htcondor && \
    conda clean --all --yes

# Install FSL
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install -qy --no-install-recommends fsl-core

# Install FreeSurfer
RUN --mount=type=cache,target=/var/cache/curl,sharing=locked \
    pushd /tmp && \
    curl -sSL -C - -o freesurfer.tar.gz "https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.2.0/freesurfer-linux-centos7_x86_64-7.2.0.tar.gz" && \
    tar -xzf freesurfer.tar.gz -C /opt && \
    rm freesurfer.tar.gz && \
    # Create a dummy license file
    echo "user@example.com" > /opt/freesurfer/license.txt && \
    echo "12345" >> /opt/freesurfer/license.txt

# Install MRtrix3
RUN . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    conda activate tvb_recon_env && \
    mamba install -y --channel=conda-forge mrtrix3 && \
    conda clean --all --yes

# Download TVB-recon source code
RUN git clone --depth 1 https://github.com/the-virtual-brain/tvb-recon.git /opt/tvb-recon

# Install TVB-recon python dependencies
RUN . "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    conda activate tvb_recon_env && \
    pip install --no-cache-dir -r /opt/tvb-recon/requirements.txt


# FINAL STAGE
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}
ARG DEBIAN_FRONTEND=noninteractive

# Create a non-root user
RUN useradd --create-home --shell /bin/bash tvb

# Copy environment from builder
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}
COPY --from=builder ${CONDA_DIR} ${CONDA_DIR}

# Copy FSL, FreeSurfer, MRtrix3 and tvb-recon from builder
COPY --from=builder /usr/share/fsl /usr/share/fsl
COPY --from=builder /opt/freesurfer /opt/freesurfer
COPY --from=builder /opt/tvb-recon /opt/tvb-recon

# Set up environment for TVB-recon
ENV APP_SPECIAL="no"
ENV APP_CMD="/opt/tvb-recon/run.sh" # Assuming a run script, adjust if necessary
ENV PROCESS_NAME="tvb-recon"
ENV APP_DATA_DIR_ARRAY=".config/tvb-recon"
ENV DATA_DIR_ARRAY=""

# Install runtime dependencies and Chorus scripts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/

USER tvb
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
