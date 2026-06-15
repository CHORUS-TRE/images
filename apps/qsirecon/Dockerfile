# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/pennlinc/qsirecon:26.0.0
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ENV APP_NAME=${APP_NAME}

WORKDIR /apps/${APP_NAME}

# noninteractive: chorus-utils.sh -a terminal pulls in keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

# World-readable for the workbench UID — targeted (not chmod -R) to avoid copying up the whole image
RUN find /opt /app/.pixi -type d ! -perm -o+rx -exec chmod o+rx {} + 2>/dev/null; \
    find /opt /app/.pixi -type f ! -perm -o+r  -exec chmod o+rX {} + 2>/dev/null; \
    true

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
