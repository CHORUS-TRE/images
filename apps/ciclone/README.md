# CiCLONE

## Setup license (local development)

CiCLONE uses FreeSurfer internally and requires a license.

1) Request a license: https://surfer.nmr.mgh.harvard.edu/registration.html
2) Copy **.env.template** to **.env** and replace the license fields inside
3) Run **build.sh**

## Production / CI-CD

For production deployments, the license is injected via environment variable by the workbench-operator.
The operator reads from a Kubernetes Secret (configured via `--license-secret-name`) and sets `FREESURFER_LICENSE` from the `freesurfer` key.

CiCLONE uses the same FreeSurfer license, so the same secret key is used for both apps.
