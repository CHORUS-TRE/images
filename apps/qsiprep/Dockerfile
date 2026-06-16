# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/pennlinc/qsiprep:26.0.0
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ENV APP_NAME=${APP_NAME}

WORKDIR /apps/${APP_NAME}

# noninteractive: chorus-utils.sh -a terminal pulls in keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

# The upstream base ships /tmp as 0755; apt drops to the _apt user during update, which then
# can't create its temp files there, so apt-get update fails. Restore the standard sticky 1777.
RUN chmod 1777 /tmp

# World-readable for the workbench UID — targeted (not chmod -R) to avoid copying up the whole
# image. Scope = the upstream install prefixes: /opt, /app/.pixi, /usr/local (AFNI), /src (TORTOISE).
RUN find /opt /app/.pixi /usr/local /src -type d ! -perm -o+rx -exec chmod o+rx {} + 2>/dev/null; \
    find /opt /app/.pixi /usr/local /src -type f ! -perm -o+r  -exec chmod o+rX {} + 2>/dev/null; \
    true

# AFNI 3d* tools (used in the preprocessing pipeline) link against libgsl.so.23, but jammy ships
# only .so.27; add the matching lib from Debian buster so they load (legacy-lib pattern, cf. micapipe).
RUN curl -fsSL --retry 5 -o /tmp/libgsl23.deb \
        http://archive.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb \
    && dpkg-deb -x /tmp/libgsl23.deb /tmp/libgsl23 \
    && cp -a /tmp/libgsl23/usr/lib/x86_64-linux-gnu/libgsl.so.23* /usr/lib/x86_64-linux-gnu/ \
    && rm -rf /tmp/libgsl23 /tmp/libgsl23.deb \
    && ldconfig && ldconfig -p | grep -q 'libgsl\.so\.23'

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
