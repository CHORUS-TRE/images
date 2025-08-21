# syntax=docker/dockerfile:1

# Stage 1: Build dependencies - FreeSurfer
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS freesurfer-builder
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG FREESURFER_VERSION=8.0.0

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get upgrade -qy && \
    apt-get install --no-install-recommends -qy \
    ca-certificates curl && \
    curl -sSO https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer_ubuntu22-${FREESURFER_VERSION}_amd64.deb && \
    dpkg-deb -x freesurfer_ubuntu22-${FREESURFER_VERSION}_amd64.deb /freesurfer-extract && \
    rm freesurfer_ubuntu22-${FREESURFER_VERSION}_amd64.deb

# Stage 2: Build dependencies - FSL
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS fsl-builder
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG FSL_VERSION=6.0.7.17

ADD https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py .

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get upgrade -qy && \
    apt-get install --no-install-recommends -qy \
    ca-certificates tar bzip2 dc file \
    libgomp1 libquadmath0 locales python3 && \
    locale-gen en_US.UTF-8 en_GB.UTF-8 && \
    sed -i -E "s/(printmsg\(([^,]+, )?end='(\\\\r)?')/# SILENCE \\1/g" ./fslinstaller.py && \
    python3 ./fslinstaller.py \
        -d /usr/local/fsl \
        -V ${FSL_VERSION} \
        --skip_registration \
        --no_self_update && \
    rm -rf /usr/local/fsl/src && \
    rm fslinstaller.py

# Stage 3: Final runtime stage
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS final
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

# Copy only essential runtime files from build stages
COPY --from=freesurfer-builder /freesurfer-extract/usr/local/freesurfer /usr/local/freesurfer
COPY --from=fsl-builder /usr/local/fsl /usr/local/fsl

# Install only runtime dependencies and CiCLONE
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get upgrade -qy && \
    apt-get install --no-install-recommends -qy \
    git python3 python3-pip \
    language-pack-en binutils gettext xterm x11-apps perl \
    make csh tcsh file bc libncurses6 \
    libgomp1 libjpeg62 libpcre2-16-0 libquadmath0 \
    libxft2 libxi6 libxrender1 libxss1 \
    tar bzip2 dc locales \
    libxcb-icccm4 libxcb-randr0 libxcb-render-util0 libxcb-render0 \
    libxcb-shape0 libxcb-xinerama0 libxcb-xinput0 libxcb-cursor0 \
    libxcb-keysyms1 libxcb-image0 libxcb-util1 \
    libxkbcommon0 libxkbcommon-x11-0 libglib2.0-0 libdbus-1-3 \
    libfontconfig1 libxcursor1 libgl1 libegl1 && \
    locale-gen en_US.UTF-8 en_GB.UTF-8 && \
    pip install --no-cache-dir --break-system-packages git+https://github.com/floriansipp/CiCLONE/@v${APP_VERSION}#egg=CiCLONE && \
    apt-get remove -y --purge git && \
    apt-get autoremove -y --purge

ENV APP_NAME=${APP_NAME}
ENV APP_SPECIAL="no"
ENV APP_CMD="ciclone"
ENV PROCESS_NAME="ciclone"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

COPY config/ /apps/${APP_NAME}/config/

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    mv entrypoint/2-copy-config.sh /docker-entrypoint.d && \
    popd
    
ENTRYPOINT ["/docker-entrypoint.sh"]
