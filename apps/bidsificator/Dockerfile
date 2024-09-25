# syntax=docker/dockerfile:1
FROM ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    git python3 python3-pip \
    # lib necessary to have a working pyqt application \
    libxcb-icccm4 libxcb-randr0 libxcb-render-util0 \
    libxcb-shape0 libxcursor1 libxkbcommon-x11-0 \
    libxcb-keysyms1 libglib2.0-0 libdbus-1-3 fontconfig \
    libfontconfig1 libxcb-image0 libxcb-util1 && \
    # install using pip and git \
    pip install --no-cache git+https://github.com/HIP-infrastructure/Bidsificator/@v${APP_VERSION}#egg=Bidsificator && \
    apt-get remove -y --purge git && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="bidsificator"
ENV PROCESS_NAME="bidsificator"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 
    
ENTRYPOINT ["/docker-entrypoint.sh"]
