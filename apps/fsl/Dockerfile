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
    ca-certificates curl dc file libgomp1 libquadmath0 locales python3 && \
    locale-gen en_US.UTF-8 en_GB.UTF-8 && \
    curl -sSL https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -o fslinstaller.py && \
    sed -i -E "s/(printmsg\(([^,]+, )?end='(\\\\r)?')/# SILENCE \\1/g" ./fslinstaller.py && \
    python3 ./fslinstaller.py \
        --conda \
        -d /usr/local/fsl \
        -V ${APP_VERSION} \
        --skip_registration && \
    rm -rf /usr/local/fsl/src && \
    rm fslinstaller.py && \
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
