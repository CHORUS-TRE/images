# syntax=docker/dockerfile:1
#
# micapipe v0.2.3 — Chorus application image.
#
# Upstream (MICA-MNI/micapipe) ships a Neurodocker-generated image based on
# Ubuntu 18.04 (micalab/micapipe:v0.2.3). Per the Chorus app model, this is a
# from-scratch rebuild on Ubuntu 24.04 that reproduces the same pinned stack,
# with the following deliberate substitutions for sources that died or were
# 18.04-specific (full rationale + risk register in README.md):
#
#   * FreeSurfer 7.3.2  : ftp:// -> https:// (identical ubuntu18 tarball)
#   * ANTs 2.4.1        : prebuilt binary, bumped from upstream's 2.3.4 — ANTsX ships
#                         no prebuilt for any 2.3.x and the Dropbox asset is dead (403);
#                         2.4.1 is the earliest official Linux release (runs on 24.04).
#   * Workbench 1.3.2   : installed from the exact NeuroDebian .deb — the HCP zip
#                         for 1.3.2 is no longer hosted (only 1.5.0 remains).
#   * FIX 1.068         : upstream download URL is dead (404). FIXPATH is wired and
#                         settings are staged, but the MATLAB-compiled FIX binary is
#                         NOT bundled (optional ICA-FIX denoising — add manually).
#   * FastSurfer        : optional surface engine; the heavy/fragile steps are guarded
#                         so they degrade instead of failing the whole build.
#   * apt package names : mapped to their Ubuntu 24.04 equivalents
#                         (lsb-release, libarchive-tools, libgl1, libncurses6, ...).
#
# Everything else (tool versions, the conda/pip `micapipe` env, AFNI, MATLAB MCR,
# c3d, MRtrix3 3.0.1, R packages) mirrors the upstream Dockerfile.

FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:26.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

# ---------------------------------------------------------------------------
# Base utilities + build toolchain
# (upstream: apt-utils bzip2 ... + gcc g++ lsb-core bsdtar jq libopenblas-dev ...)
# 24.04 swaps: lsb-core -> lsb-release, bsdtar -> libarchive-tools, openjdk-8 -> 17.
# ---------------------------------------------------------------------------
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        apt-utils bzip2 ca-certificates curl wget locales unzip xz-utils \
        gcc g++ make cmake git pigz zlib1g-dev \
        jq tree libopenblas-dev libstdc++6 \
        lsb-release libarchive-tools openjdk-17-jre-headless \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# dcm2niix v1.0.20190902 (built from source, as upstream)
# ---------------------------------------------------------------------------
ENV PATH="/opt/dcm2niix-v1.0.20190902/bin:$PATH"
RUN git clone https://github.com/rordenlab/dcm2niix /tmp/dcm2niix \
    && cd /tmp/dcm2niix \
    && git fetch --tags \
    && git checkout v1.0.20190902 \
    && mkdir /tmp/dcm2niix/build && cd /tmp/dcm2niix/build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/dcm2niix-v1.0.20190902 .. \
    && make && make install \
    && rm -rf /tmp/dcm2niix

# ---------------------------------------------------------------------------
# FSL 6.0.2 (prebuilt centos6 tarball — fslinstaller cannot install <6.0.6)
# ---------------------------------------------------------------------------
ENV FSLDIR="/opt/fsl-6.0.2" \
    PATH="/opt/fsl-6.0.2/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-6.0.2/bin/fsltclsh" \
    FSLWISH="/opt/fsl-6.0.2/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        bc dc file libfontconfig1 libfreetype6 \
        libgl1 libglx-mesa0 libglu1-mesa libgl1-mesa-dri libgomp1 \
        libice6 libxcursor1 libxft2 libxinerama1 libxrandr2 libxrender1 libxt6 sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading FSL 6.0.2 ..." \
    && mkdir -p /opt/fsl-6.0.2 \
    && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.2-centos6_64.tar.gz \
       | tar -xz -C /opt/fsl-6.0.2 --strip-components 1
# FSL's bundled python (fslpython); guarded — micapipe core does not depend on it
RUN bash /opt/fsl-6.0.2/etc/fslconf/fslpython_install.sh -f /opt/fsl-6.0.2 \
    || echo "WARN: fslpython_install.sh failed; fslpython tools may be unavailable"

# ---------------------------------------------------------------------------
# FreeSurfer 7.3.2 (ubuntu18 tarball; ftp:// -> https://). Excludes mirror upstream.
# ---------------------------------------------------------------------------
ENV FREESURFER_HOME="/opt/freesurfer-7.3.2" \
    PATH="/opt/freesurfer-7.3.2/bin:$PATH"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        bc libgomp1 libxmu6 libxt6 perl tcsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading FreeSurfer 7.3.2 ..." \
    && mkdir -p /opt/freesurfer-7.3.2 \
    && curl -fsSL --retry 5 https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.3.2/freesurfer-linux-ubuntu18_amd64-7.3.2.tar.gz \
       | tar -xz -C /opt/freesurfer-7.3.2 --strip-components 1 \
         --exclude='freesurfer/average/mult-comp-cor' \
         --exclude='freesurfer/lib/cuda' \
         --exclude='freesurfer/lib/qt' \
         --exclude='freesurfer/subjects/V1_average' \
         --exclude='freesurfer/subjects/bert' \
         --exclude='freesurfer/subjects/cvs_avg35' \
         --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
         --exclude='freesurfer/subjects/fsaverage3' \
         --exclude='freesurfer/subjects/fsaverage4' \
         --exclude='freesurfer/subjects/fsaverage5' \
         --exclude='freesurfer/subjects/fsaverage6' \
         --exclude='freesurfer/subjects/fsaverage_sym' \
         --exclude='freesurfer/trctrain'

# ---------------------------------------------------------------------------
# MATLAB Compiler Runtime R2017b (v93) — needed by FIX and FSL/FS compiled tools.
# 24.04 swap: libncurses5 -> libncurses6.
# ---------------------------------------------------------------------------
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu:/opt/matlabmcr-2017b/v93/runtime/glnxa64:/opt/matlabmcr-2017b/v93/bin/glnxa64:/opt/matlabmcr-2017b/v93/sys/os/glnxa64:/opt/matlabmcr-2017b/v93/extern/bin/glnxa64" \
    MATLABCMD="/opt/matlabmcr-2017b/v93/toolbox/matlab"
RUN export TMPDIR="$(mktemp -d)" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        bc libncurses6 libxext6 libxmu6 libxpm-dev libxt6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading MATLAB Compiler Runtime R2017b ..." \
    && curl -fsSL --retry 5 -o "$TMPDIR/mcr.zip" https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip \
    && unzip -q "$TMPDIR/mcr.zip" -d "$TMPDIR/mcrtmp" \
    && "$TMPDIR/mcrtmp/install" -destinationFolder /opt/matlabmcr-2017b -mode silent -agreeToLicense yes \
    && rm -rf "$TMPDIR"

# ---------------------------------------------------------------------------
# AFNI (generic linux_openmp_64 build, as upstream). Pulls two legacy shared libs
# (libXp6, libpng12) that are not in the 24.04 archive, and aliases libgsl -> .so.0.
# ---------------------------------------------------------------------------
ENV PATH="/opt/afni-latest:$PATH" \
    AFNI_PLUGINPATH="/opt/afni-latest"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        ed gsl-bin libglib2.0-0 libglu1-mesa libglw1-mesa libgomp1 \
        libjpeg-turbo8 libxm4 netpbm tcsh xfonts-base xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "Installing legacy libs required by the AFNI binaries ..." \
    && curl -sSL --retry 5 -o /tmp/libxp6.deb http://launchpadlibrarian.net/160108232/libxp6_1.0.2-1ubuntu1_amd64.deb \
    && (dpkg -i /tmp/libxp6.deb || apt-get install -fy) && rm /tmp/libxp6.deb \
    && curl -sSL --retry 5 -o /tmp/libpng12.deb "http://snapshot.debian.org/archive/debian-security/20160113T213056Z/pool/updates/main/libp/libpng/libpng12-0_1.2.49-1%2Bdeb7u2_amd64.deb" \
    && (dpkg -i /tmp/libpng12.deb || apt-get install -fy) && rm /tmp/libpng12.deb \
    && gsl_path="$(find / -name 'libgsl.so.*' ! -name '*.so.0' 2>/dev/null | head -n1 || printf '')" \
    && if [ -n "$gsl_path" ]; then ln -sfv "$gsl_path" "$(dirname "$gsl_path")/libgsl.so.0"; fi \
    && ldconfig \
    && echo "Downloading AFNI ..." \
    && mkdir -p /opt/afni-latest \
    && curl -fsSL --retry 5 https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz \
       | tar -xz -C /opt/afni-latest --strip-components 1

# ---------------------------------------------------------------------------
# ANTs 2.4.1 — prebuilt binary (bumped from upstream's 2.3.4: ANTsX ships no prebuilt
# for any 2.3.x and the original Dropbox asset is dead, so we use the earliest official
# Linux release). The ubuntu-22.04 build is forward-compatible with noble. The archive
# extracts to /opt/ants-2.4.1/{bin,lib}.
# ---------------------------------------------------------------------------
ENV ANTSPATH="/opt/ants-2.4.1/bin" \
    PATH="/opt/ants-2.4.1/bin:$PATH"
RUN echo "Downloading ANTs 2.4.1 ..." \
    && curl -fsSL --retry 5 -o /tmp/ants.zip \
        https://github.com/ANTsX/ANTs/releases/download/v2.4.1/ants-2.4.1-ubuntu-22.04-X64-gcc.zip \
    && unzip -q /tmp/ants.zip -d /opt \
    && rm /tmp/ants.zip

# ---------------------------------------------------------------------------
# Connectome Workbench 1.3.2 (exact NeuroDebian .deb; installs wb_command to /usr/bin).
# Fallback if Qt deps cannot be satisfied on 24.04: HCP workbench-linux64-v1.5.0.zip
# (still hosted) — see README.md.
# ---------------------------------------------------------------------------
RUN echo "Installing Connectome Workbench 1.3.2 ..." \
    && curl -fsSL --retry 5 -o /tmp/cw.deb \
        "http://neuro.debian.net/debian/pool/main/c/connectome-workbench/connectome-workbench_1.3.2-2~nd16.04+1_amd64.deb" \
    && apt-get update -qq \
    && (dpkg -i /tmp/cw.deb || apt-get install -fy --no-install-recommends) \
    && rm /tmp/cw.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# FIX 1.068 — upstream download URL is dead (404). The binary is NOT bundled.
# We create the directory and wire FIXPATH so micapipe finds the layout; the
# MATLAB-compiled FIX must be dropped into /opt/fix1.068 manually if ICA-FIX
# denoising is needed (requires the MCR above + the R packages below).
# ---------------------------------------------------------------------------
RUN mkdir -p /opt/fix1.068

# ---------------------------------------------------------------------------
# Miniconda 22.11.1 + the `micapipe` conda/pip environment (verbatim package set).
# Installed under /opt as root (Chorus runs as the workbench user, not `mica`).
# mamba (libsolv) does the solve instead of conda's classic solver — same channels
# and pins, identical resulting packages, but a fraction of the memory/time (the
# classic solver OOMs solving this 60-package env, especially under emulation).
# ---------------------------------------------------------------------------
ENV CONDA_DIR="/opt/miniconda-22.11.1" \
    PATH="/opt/miniconda-22.11.1/bin:$PATH"
RUN echo "Downloading Miniconda installer ..." \
    && curl -fsSL --retry 5 -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py39_22.11.1-1-Linux-x86_64.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda-22.11.1 \
    && rm -f /tmp/miniconda.sh \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && conda install -n base -y -c conda-forge mamba \
    && conda clean -y --all \
    && mamba create -y -q --name micapipe \
    && mamba install -y -q --name micapipe \
        "python" \
        "aiohttp" "aiosignal" "asn1crypto" "async-timeout" "astropy" "attrs" \
        "bokeh" "cffi" "charset-normalizer" "click" "contourpy" "cryptography" \
        "cycler" "fonttools" "frozenlist" "html5lib" "idna" "importlib-resources" \
        "jinja2" "joblib" "kiwisolver" "lxml" "markupsafe" "matplotlib==3.4.3" \
        "multidict" "nibabel==4.0.2" "nilearn" "numpy==1.21.5" "packaging" \
        "pandas==1.4.4" "pillow" "pycparser" "pyhanko-certvalidator" "pyparsing" \
        "pypdf" "pypng" "python-bidi" "python-dateutil" "pytz" \
        "pytz-deprecation-shim" "pyyaml" "qrcode" "reportlab" "requests" \
        "scikit-learn" "scikit-fmm" "scipy" "six" "svglib" "threadpoolctl" \
        "tinycss2" "tornado" "typing-extensions" "tzlocal" "uritools" "urllib3" \
        "vtk==9.2.2" "webencodings" "wslink" "yarl" "zipp" "pyvirtualdisplay==3.0" \
    && conda clean -y --all \
    && source /opt/miniconda-22.11.1/etc/profile.d/conda.sh \
    && conda activate micapipe \
    && pip install --no-cache-dir \
        "argparse==1.1" "brainspace==0.1.10" "tedana==0.0.12" "duecredit" \
        "pyhanko==0.17.2" "mapca==0.0.3" "xhtml2pdf==0.2.9" "oscrypto==1.3.0" \
        "tzdata==2022.7" "arabic-reshaper==3.0.0" "cssselect2==0.7.0" \
        "pygeodesic==0.1.8" "seaborn==0.11.2" \
    && rm -rf ~/.cache/pip/*

# ---------------------------------------------------------------------------
# MRtrix3 3.0.1 (mamba) + ENIGMA toolbox, into the micapipe env.
# ---------------------------------------------------------------------------
RUN source /opt/miniconda-22.11.1/etc/profile.d/conda.sh \
    && conda activate micapipe \
    && mamba install -y -q -c mrtrix3 mrtrix3==3.0.1 \
    && pip install --no-cache-dir git+https://github.com/MICA-MNI/ENIGMA.git \
    && conda clean -y --all && rm -rf ~/.cache/pip/*

# ---------------------------------------------------------------------------
# FastSurfer (OPTIONAL surface engine; default surfaces use FreeSurfer recon-all).
# Heaviest/most fragile block: old "stable" env solve + ~GB model weights. Guarded so
# a failure leaves FastSurfer non-functional rather than breaking the image build.
# Remove this whole block if FastSurfer surfaces are not needed.
# ---------------------------------------------------------------------------
ENV FASTSURFER_HOME="/opt/FastSurfer" \
    PATH="/opt/FastSurfer:$PATH" \
    PYTHONPATH="${PYTHONPATH}:/opt/FastSurfer"
RUN git clone https://github.com/Deep-MI/FastSurfer.git /opt/FastSurfer \
    && cd /opt/FastSurfer && git checkout stable \
    && curl -fsSL --retry 5 -o /tmp/miniconda2.sh https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh \
    && bash /tmp/miniconda2.sh -b -p /opt/conda && rm /tmp/miniconda2.sh \
    && ( /opt/conda/bin/conda env create -f /opt/FastSurfer/fastsurfer_env_cpu.yml \
         && source /opt/conda/bin/activate fastsurfer_cpu \
         && cd /opt/FastSurfer && python FastSurferCNN/download_checkpoints.py --all ) \
       || echo "WARN: FastSurfer env/checkpoints failed — FastSurfer surfaces unavailable (FreeSurfer recon-all still works)"

# ---------------------------------------------------------------------------
# R + packages. Upstream uses the bionic-cran35 repo (R 3.6); on 24.04 we use the
# official CRAN noble repo (R 4.x). The pinned package versions in install_R_env.sh
# are R 3.x-era, so the script is run best-effort — these R packages are only used by
# FSL-FIX (not bundled) and AFNI's rPkgsInstall, not by micapipe's core processing.
# ---------------------------------------------------------------------------
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
        software-properties-common apt-transport-https dirmngr gpg-agent \
        libblas-dev liblapack-dev gfortran libgl1 libxml2-dev libssl-dev libcurl4-openssl-dev \
    && curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
       | gpg --dearmor -o /usr/share/keyrings/r-project.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
       > /etc/apt/sources.list.d/r-project.list \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends r-base r-base-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# c3d 1.0.0 (Convert3D)
# ---------------------------------------------------------------------------
RUN echo "Downloading c3d 1.0.0 ..." \
    && curl -fsSL --retry 5 -o /tmp/c3d.tar.gz "https://sourceforge.net/projects/c3d/files/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz/download" \
    && tar -xf /tmp/c3d.tar.gz -C /opt/ \
    && rm /tmp/c3d.tar.gz
ENV PATH="/opt/c3d-1.0.0-Linux-x86_64/bin:$PATH"

# ---------------------------------------------------------------------------
# micapipe source (v0.2.3) + its post-install wiring (FIX settings, FSL flirt
# schedules, fsaverage5 into the FreeSurfer subjects dir). Then run the R env setup.
# ---------------------------------------------------------------------------
RUN git clone --depth 1 --branch v0.2.3 https://github.com/MICA-MNI/micapipe.git /opt/micapipe \
    && cp /opt/micapipe/R_config/* /opt/ \
    && mv /opt/micapipe/fix_settings.sh /opt/fix1.068/settings.sh \
    && mkdir -p /opt/fsl-6.0.2/etc/flirtsch \
    && cp /opt/micapipe/fsl_conf/* /opt/fsl-6.0.2/etc/flirtsch/ \
    && cp -r /opt/micapipe/surfaces/fsaverage5 /opt/freesurfer-7.3.2/subjects/

RUN bash /opt/install_R_env.sh \
       || echo "WARN: some R packages failed to install on R 4.x (pinned versions are R 3.x-era; used only by FSL-FIX)" \
    && ( cd /opt/afni-latest && rPkgsInstall -pkgs ALL ) \
       || echo "WARN: AFNI rPkgsInstall failed — AFNI R packages unavailable"

# ---------------------------------------------------------------------------
# micapipe runtime environment (mirrors the upstream final ENV block)
# ---------------------------------------------------------------------------
ENV MICAPIPE="/opt/micapipe" \
    PROC="container_micapipe-v0.2.3" \
    FIXPATH="/opt/fix1.068" \
    PATH="/opt/fix1.068:/opt/micapipe:/opt/micapipe/functions:$PATH"

# The workbench user runs as a Chorus-assigned UID (not root, not `mica`); make the
# whole toolchain world-readable/executable.
RUN chmod -R a+rX /opt

# ===========================================================================
# Chorus app integration — runs micapipe interactively from a terminal (like
# ANTs/MRtrix3/FSL). All tool setup + the FreeSurfer license lives in
# config/.bash_profile, sourced by the login shell that launches the terminal.
# ===========================================================================
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

COPY ./config/ /apps/${APP_NAME}/config/

# Install vgl + terminal + libnss-wrapper + entrypoint for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal \
    && cp /tmp/core_scripts/app/docker-entrypoint.sh / \
    && cp /tmp/core_scripts/app/1-copy-config.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
