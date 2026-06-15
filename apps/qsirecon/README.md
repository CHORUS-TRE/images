# QSIRecon

[QSIRecon](https://qsirecon.readthedocs.io/) (PennLINC, University of
Pennsylvania) is the post-processing counterpart to QSIPrep. From
**already-preprocessed** diffusion MRI (dMRI) derivatives it produces
biologically meaningful outputs: ODF/FOD reconstruction, model fits and
parameter estimation (DTI, DKI, NODDI, MAP-MRI, GQI), tractography,
tractometry, and regional connectivity matrices. It bundles state-of-the-art
methods from Dipy, MRtrix3, DSI Studio, and PyAFQ behind a single curated set
of reconstruction workflows.

It is a **command-line BIDS-app**, not a GUI tool. In Chorus it runs like the
other command-line neuro apps (micapipe, ANTs, MRtrix3, FSL): the app opens a
terminal in which the `qsirecon` command and its whole toolchain are already on
`PATH`.

## Input data

QSIRecon does **not** preprocess raw dMRI — it consumes a preprocessed
dMRI derivatives dataset, typically produced by
[QSIPrep](https://qsiprep.readthedocs.io/). Point it at that derivatives
directory, not at a raw BIDS dataset.

## Running it

```bash
qsirecon /path/to/preprocessed-derivatives /path/to/output participant \
         --recon-spec mrtrix_multishell_msmt_ACT-hsvs \
         --fs-license-file "$FS_LICENSE" \
         --nthreads 6
```

`FS_LICENSE` is pre-set in the environment (see below). See the
[QSIRecon docs](https://qsirecon.readthedocs.io/en/latest/) for the available
reconstruction specs (`--recon-spec`) and the full option list.

## FreeSurfer license

QSIRecon uses FreeSurfer internally and requires a FreeSurfer license. The
license is injected by the workbench-operator via the `FREESURFER_LICENSE`
environment variable, using the same `freesurfer` secret as the FreeSurfer,
CiCLONE, and micapipe apps. The `.bash_profile` writes it to `$HOME/license.txt`
and exports `FS_LICENSE` at startup. To request a license:
https://surfer.nmr.mgh.harvard.edu/registration.html

## Packaging notes (layered on the upstream image)

Unlike micapipe — whose upstream ships on Ubuntu 18.04 and therefore had to be
rebuilt from scratch on a Chorus-supported base — QSIRecon's official image
(`pennlinc/qsirecon`) is already built on a Chorus-supported base: its runtime
stage is `nvidia/cuda:12.2.2-runtime-ubuntu22.04` (Ubuntu 22.04, glibc 2.35).
This image therefore **layers the Chorus app integration directly on top of the
upstream image** rather than reproducing its large, version-locked stack.

The upstream image bundles, in its `pennlinc/qsirecon-base` layer, prebuilt
FreeSurfer, ANTs, MRtrix3, MRtrix3Tissue, DSI Studio, AFNI, and TORTOISE, plus a
[pixi](https://pixi.sh/)-locked Python 3.10 environment at
`/app/.pixi/envs/qsirecon` (Dipy, PyAFQ, FSL, AMICO, …). All of it is already on
`PATH` through the image `ENV`, which the container inherits.

The Chorus layer adds only: the interactive terminal (`kitty`),
`libnss-wrapper`, VirtualGL, the Chorus entrypoint, the FreeSurfer license
wiring in `config/.bash_profile`, and the catalog metadata in `labels`.

### Notes

- **GPU**: the upstream base is a CUDA runtime image, but the reconstruction
  workflows run **CPU-only** in Chorus. GPU-accelerated paths (e.g.
  TORTOISE-cuda) are not currently exposed.
- **Image size**: large (CUDA runtime + the full neuro stack). `cache-mode` is
  set to `min` accordingly.
- **Resource limits** in `labels` mirror micapipe as a starting point;
  tractography and autotrack can be memory-heavy — revisit after validating on a
  representative dataset.
- **Maintenance**: bump the `FROM` tag in the `Dockerfile` and the
  `app-version` / `changelog` in `labels` on each upstream release —
  https://github.com/PennLINC/qsirecon/releases.
