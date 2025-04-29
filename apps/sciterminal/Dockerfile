# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG PLINK_VERSION
ARG BCFTOOLS_VERSION
ARG SHAPEIT_VERSION
ARG IMPUTE_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    curl unzip ca-certificates cmake build-essential \
    #plink2 \
    bzip2 \
    #bcftools \
    libbz2-dev zlib1g-dev liblzma-dev libcurl4-openssl-dev && \
    #install plink2 \
    mkdir plink2 && \
    cd plink2 && \
    curl -sSOL https://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_${PLINK_VERSION}.zip && \
    unzip plink2_linux_x86_64_*.zip && \
    rm plink2_linux_x86_64_*.zip && \
    cd ../ && \
    #install bcftools \
    mkdir bcftools && \
    curl -sSOL https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    tar jxvf bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    rm bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    cd bcftools-${BCFTOOLS_VERSION} && \
    ./configure --prefix=/apps/${APP_NAME}/bcftools && \
    make -j7 && \
    make install && \
    cd ../ && \
    rm -rf bcftools-${BCFTOOLS_VERSION} && \
    #install shapeit5 \
    mkdir shapeit5 && \
    cd shapeit5 && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/ligate_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/phase_common_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/phase_rare_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/simulate_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/shapeit_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v${SHAPEIT_VERSION}/shapeit4_static && \
    chmod -R 755 . && \
    cd ../ && \
    #install impute5 \
    curl -sSOL https://www.dropbox.com/sh/mwnceyhir8yze2j/AABKBCgZsQqz8TlZGo7yXwx6a/impute5_v${IMPUTE_VERSION}.zip && \
    unzip -q -d . impute5_v${IMPUTE_VERSION}.zip && \
    mv impute5_v${IMPUTE_VERSION} impute5 && \
    rm impute5_v${IMPUTE_VERSION}.zip && \
    rm -rf __MACOSX && \
    rm -rf impute5/test && \
    chmod -R 755 impute5 && \
    #cleanup
    apt-get remove -y --purge curl unzip cmake build-essential bzip2 && \
    apt-get autoremove -y --purge

ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}/plink2:/apps/${APP_NAME}/bcftools/bin:/apps/${APP_NAME}/shapeit5:/apps/${APP_NAME}/impute5:${PATH}"
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh -a terminal && \
    cp entrypoint/docker-entrypoint.sh / && \
    cp entrypoint/1-create-user.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
