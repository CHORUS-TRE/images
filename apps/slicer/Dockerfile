# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG PLINK_VERSION
ARG BCFTOOLS_VERSION
ARG SHAPEIT_VERSION
ARG IMPUTE_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl ca-certificates libsm6 libxt6 libpulse-mainloop-glib0 \
    libxcb-icccm4 libxdamage1 libnss3 libqt5gui5 libxcomposite1 \
    libxrandr2 libxcursor1 libxi6 libasound2t64 libgssapi-krb5-2 libgomp1 && \
    curl -sSJOL "http://download.slicer.org/download?os=linux&stability=release&version=${APP_VERSION}" && \
    tar xzf Slicer-*-linux-amd64.tar.gz --no-same-owner && \
    mv Slicer-*-linux-amd64 Slicer && \
    rm Slicer-*-linux-amd64.tar.gz && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_NAME=${APP_NAME}
ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/Slicer/Slicer"
ENV PROCESS_NAME="Slicer"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh -a terminal && \
    cp entrypoint/docker-entrypoint.sh / && \
    cp entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd

ENTRYPOINT ["/docker-entrypoint.sh"]
