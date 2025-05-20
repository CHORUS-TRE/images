# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    curl ca-certificates language-pack-en binutils libx11-dev \
    gettext xterm x11-apps perl make csh tcsh file bc xorg \
    xorg-dev xserver-xorg-video-intel libncurses5 libdrm2 libegl1 \
    libexpat1 libfontconfig1 libfreetype6 libgl1 libglib2.0-0 \
    libglu1-mesa libglu1 libglvnd0 libglx0 libgomp1 libice6 \
    libjpeg62 libopengl0 libpng16-16 libquadmath0 libsm6 \
    libwayland-client0 libwayland-cursor0 libx11-6 libx11-xcb1 \
    libxcb-icccm4 libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 \
    libxcb-sync1 libxcb-xfixes0 libxcb-xinerama0 libxcb-xinput0 libxext6 libxft2 \
    libxcb-image0 libxcb-keysyms1 libxcb-xkb1 libxkbcommon-x11-0 libxkbcommon0 \
    libxi6 libxmu6 libxrender1 libxss1 libxt6 && \
    curl -sSO https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${APP_VERSION}/freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    dpkg -i freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    rm freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_NAME=${APP_NAME}
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

COPY ./config/ /apps/${APP_NAME}/config/

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh -a terminal && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    mv entrypoint/2-copy-config.sh /docker-entrypoint.d && \
    popd
    
ENTRYPOINT ["/docker-entrypoint.sh"]
