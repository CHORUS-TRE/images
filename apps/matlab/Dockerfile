# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:26.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

# Reference for dependencies for each MATLAB version:
# https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-deps
# Issue for R2023a and Ubuntu22.04:
# https://www.mathworks.com/matlabcentral/answers/1978579-why-do-some-matlab-features-fail-on-ubuntu-23-04-and-debian-12-with-exit-code-127-in-matlab-r2022b-a
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -y \
    curl ca-certificates libatomic1 libasound2 libc6 libcairo-gobject2 libcairo2 libcap2 \
    libcrypt1 libcups2 libdrm2 libgbm1 libgdk-pixbuf-2.0-0 libgl1 libglib2.0-0 \
    libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk-3-0 libice6 libnspr4 \
    libnss3 libodbc2 libodbcinst2 libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
    libpython3.10 libsndfile1 libuuid1 libwayland-client0 libxcomposite1 libxcursor1 libxdamage1 \
    libxfixes3 libxft2 libxinerama1 libxrandr2 libxt6 libxtst6 libxxf86vm1 locales locales-all \
    make net-tools procps unzip zlib1g && \
    mkdir /apps/mpm && \
    cd /apps/mpm && \
    curl -sSOL https://www.mathworks.com/mpm/glnxa64/mpm && \
    chmod +x mpm && \
    ./mpm install --release=R2023a --destination=/opt/matlab/R2023a MATLAB Signal_Processing_Toolbox Parallel_Computing_Toolbox && \
    cd .. && \
    # If libfreetype.so.6 is not removed, java error when trying to open the matlab code editor \
    rm -rf /opt/matlab/R2023a/bin/glnxa64/libfreetype.so.6 && \
    rm -rf /apps/mpm && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/opt/matlab/${APP_VERSION}/bin/matlab -desktop -nosplash"
ENV PROCESS_NAME="matlab"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
