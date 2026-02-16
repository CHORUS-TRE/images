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
    pv bc vim && \
    #apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty --title Benchmark bash -c \"/apps/${APP_NAME}/run.sh; exec bash\""
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /

# Install benchmarking scripts
COPY scripts ./

ENTRYPOINT ["/docker-entrypoint.sh"]
