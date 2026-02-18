# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    software-properties-common && \
    # Add deadsnakes PPA for Python 3.13 \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    git python3.13 python3.13-venv \
    # Qt6/PySide6 dependencies for GUI application \
    libxcb-icccm4 libxcb-randr0 libxcb-render-util0 \
    libxcb-shape0 libxcursor1 libxkbcommon-x11-0 \
    libxcb-keysyms1 libglib2.0-0 libdbus-1-3 fontconfig \
    libfontconfig1 libxcb-image0 libxcb-util1 libxcb-cursor0 \
    libxcb-xinerama0 libegl1 libgl1 libxkbcommon0 \
    # Additional Qt6 dependencies \
    libxcb-glx0 libxcb-xfixes0 && \
    # Bootstrap pip for Python 3.13 \
    python3.13 -m ensurepip --upgrade && \
    python3.13 -m pip install --no-cache --break-system-packages --upgrade pip setuptools wheel && \
    # Clone bidsio, install dependencies, compile UI files, then install \
    git clone --depth 1 https://github.com/CRNL-Eduwell/bidsio.git /tmp/bidsio && \
    sed -i '/pyside6-webengine/d' /tmp/bidsio/requirements.txt && \
    python3.13 -m pip install --no-cache --break-system-packages -r /tmp/bidsio/requirements.txt && \
    python3.13 /tmp/bidsio/scripts/generate_ui.py && \
    python3.13 -m pip install --no-cache --break-system-packages /tmp/bidsio && \
    rm -rf /tmp/bidsio && \
    apt-get remove -y --purge git software-properties-common && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="python3.13 -m bidsio.ui.app"
ENV PROCESS_NAME="python3.13"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /
    
ENTRYPOINT ["/docker-entrypoint.sh"]
