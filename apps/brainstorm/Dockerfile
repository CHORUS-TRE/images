# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG MAT_VERSION
ARG MAT_UPDATE

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
# matlab-runtime
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    ca-certificates curl unzip libxt6 && \
    pushd /var/cache/curl && \
    curl -sSO -C - https://ssd.mathworks.com/supportfiles/downloads/${MAT_VERSION}/Release/${MAT_UPDATE}/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_${MAT_VERSION}_Update_${MAT_UPDATE}_glnxa64.zip && \
    popd && \
    unzip -q -d files /var/cache/curl/MATLAB_Runtime_${MAT_VERSION}_Update_${MAT_UPDATE}_glnxa64.zip && \
    ./files/install -agreeToLicense yes -mode silent && \
    rm -rf files && \
    rm -rf /usr/local/MATLAB/MATLAB_Runtime/v9*/sys/os/glnxa64/libstdc++.so.6 && \
    apt-get remove -y --purge \
        curl \
        unzip && \
    apt-get autoremove -y --purge

# brainstorm
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl \
        default-jre \
        unzip && \
    curl -sSJ -O "http://neuroimage.usc.edu/bst/getupdate.php?c=UbsM09&src=0&bin=1" && \
    mkdir install && \
    unzip -q -d install brainstorm_*_bin.zip && \
    rm -r brainstorm_*_bin.zip && \
    apt-get remove -y --purge \
        curl \
        unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/brainstorm3/bin/R2023a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/R2023a"
ENV PROCESS_NAME="brainstorm3.jar"
ENV APP_DATA_DIR_ARRAY="brainstorm_db .brainstorm"
#ENV APP_DATA_DIR_ARRAY="brainstorm_db .brainstorm .mcrCache9.8"
ENV DATA_DIR_ARRAY=""

COPY . .

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
