# QSIPrep

[QSIPrep](https://qsiprep.readthedocs.io/) (PennLINC, University of
Pennsylvania) configures robust preprocessing pipelines for diffusion-weighted
MRI (dMRI). From a **raw BIDS dataset** it performs head-motion correction,
susceptibility distortion correction, denoising and Gibbs-unringing,
coregistration and spatial normalization, producing analysis-ready preprocessed
derivatives plus visual QC reports, confounds, and transform files. It builds on
Nipype and a BIDS-app interface and curates methods from FSL, ANTs, MRtrix3,
DSI Studio, AFNI, and TORTOISE behind a single command.

It is a **command-line BIDS-app**, not a GUI tool. In Chorus it runs like the
other command-line neuro apps (qsirecon, micapipe, ANTs, MRtrix3, FSL): the app
opens a terminal in which the `qsiprep` command and its whole toolchain are
already on `PATH`.

## Input data

QSIPrep consumes a **raw BIDS dataset** (the `sub-XXXXX` folders at the top
level), not preprocessed derivatives. Its output is the preprocessed dMRI
derivatives dataset that
[QSIRecon](https://qsirecon.readthedocs.io/) then post-processes — the two apps
are the two halves of the same pipeline.

## Running it

```bash
qsiprep /path/to/bids /path/to/output participant \
        -w /path/to/work \
        --output-resolution 2 \
        --fs-license-file "$FS_LICENSE" \
        --nthreads 6
```

`FS_LICENSE` is pre-set in the environment (see below). See the
[QSIPrep docs](https://qsiprep.readthedocs.io/en/latest/) for the full option
list (`--output-resolution` is required).

## FreeSurfer license

A FreeSurfer license is **optional** for QSIPrep — only the workflows that call
FreeSurfer need it — but Chorus wires it the same way as the other neuro apps so
it is available when needed. The license is injected by the workbench-operator
via the `FREESURFER_LICENSE` environment variable, using the same `freesurfer`
secret as the FreeSurfer, CiCLONE, micapipe, and QSIRecon apps. The
`.bash_profile` writes it to `$HOME/license.txt` and exports `FS_LICENSE` at
startup. To request a license:
https://surfer.nmr.mgh.harvard.edu/registration.html

## Packaging notes (layered on the upstream image)

Unlike micapipe — whose upstream ships on Ubuntu 18.04 and therefore had to be
rebuilt from scratch on a Chorus-supported base — QSIPrep's official image
(`pennlinc/qsiprep`) is already built on a Chorus-supported base
(`pennlinc/qsiprep-base`, Ubuntu 22.04 / glibc 2.35). This image therefore
**layers the Chorus app integration directly on top of the upstream image**
rather than reproducing its large, version-locked stack. (QSIRecon layers on the
same base the same way.)

The upstream image bundles, in its `pennlinc/qsiprep-base` layer, prebuilt
FreeSurfer, ANTs, FSL, MRtrix3, AFNI, DSI Studio, and TORTOISE, plus a
[pixi](https://pixi.sh/)-locked Python environment at
`/app/.pixi/envs/qsiprep`. All of it is already on `PATH` through the image
`ENV`, which the container inherits.

The Chorus layer adds only: the interactive terminal (`kitty`),
`libnss-wrapper`, VirtualGL, the Chorus entrypoint, the FreeSurfer license
wiring in `config/.bash_profile`, the catalog metadata in `labels`, and a
one-off `libgsl.so.23` fix for the inherited AFNI tools (see Notes).

### Notes

- **GPU**: the upstream base is a CUDA runtime image, but the preprocessing
  workflows run **CPU-only** in Chorus. GPU-accelerated paths (e.g.
  `eddy_cuda`, TORTOISE-cuda) are not currently exposed.
- **AFNI / libgsl**: the AFNI `3d*` tools are built against `libgsl.so.23`, but
  the jammy base ships only `libgsl.so.27`; the Dockerfile installs the matching
  lib from Debian buster so they load. QSIPrep's preprocessing pipeline does call
  AFNI, so this is required for those steps to run.
- **`/tmp` permissions**: the upstream base ships `/tmp` as `0755`, so apt's
  unprivileged `_apt` sandbox user cannot create its temp files there and
  `apt-get update` fails (which is what `chorus-utils.sh` runs). The Dockerfile
  restores the standard sticky `1777` mode before installing the Chorus layer.
- **Image size**: large (CUDA runtime + the full neuro stack). `cache-mode` is
  set to `min` accordingly.
- **Resource limits** in `labels` mirror micapipe/QSIRecon as a starting point;
  eddy and distortion correction can be memory- and storage-heavy — revisit
  after validating on a representative dataset.
- **Maintenance**: bump the `FROM` tag in the `Dockerfile` and the
  `app-version` / `changelog` in `labels` on each upstream release
  (https://github.com/PennLINC/qsiprep/releases). The `FROM` is tag-pinned
  (not digest-pinned), per the repo's `library/ubuntu` convention — a re-pushed
  upstream `26.0.0` would silently change the whole baked toolchain, so pin by
  digest if strict reproducibility is needed.
