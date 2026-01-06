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
    curl ca-certificates language-pack-en binutils \
    libx11-dev gettext xterm x11-apps perl make csh tcsh file bc \
    xorg xorg-dev xserver-xorg-video-intel libncurses5 libbsd0 \
    libegl1 libexpat1 libfontconfig1 libfreetype6 libgl1 libglib2.0-0 \
    libglu1-mesa libglvnd0 libglx0 libgomp1 libice6 libicu70 libjpeg62 \
    libmd0 libopengl0 libpcre2-16-0 libpng16-16 libquadmath0 libsm6 \
    libx11-6 libx11-xcb1 libxau6 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-render0 \
    libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb-util1 libxcb-xfixes0 \
    libxcb-xinerama0 libxcb-xinput0 libxcb-xkb1 libxcb1 libxdmcp6 \
    libxext6 libxft2 libxi6 libxkbcommon-x11-0 libxkbcommon0 libxmu6 \
    libxrender1 libxss1 libxt6 dbus-x11 libcanberra-gtk3-module libcanberra-gtk-module && \
    curl -sSO https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${APP_VERSION}/freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    dpkg -i freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    rm freesurfer_ubuntu22-${APP_VERSION}_amd64.deb && \
    mkdir -p /apps/${APP_NAME}/subjects && \
    chown -R 1001:1001 /apps/${APP_NAME}/subjects && \
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
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/1-copy-config.sh /docker-entrypoint.d/
    
ENTRYPOINT ["/docker-entrypoint.sh"]
