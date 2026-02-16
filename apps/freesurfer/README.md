# Freesurfer

## Setup license (local development)

1) Request a license : https://surfer.nmr.mgh.harvard.edu/registration.html
2) Copy **.env.template** to **.env** and replace the license fields inside
3) Run **build.sh**

## Production / CI-CD

For production deployments, the license is injected via environment variable by the workbench-operator.
The operator reads from a Kubernetes Secret (configured via `--license-secret-name`) and sets `FREESURFER_LICENSE` from the `freesurfer` key.

The `.bash_profile` checks for the env var first, so no `.env` file is needed in the image.

Example secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-licenses
stringData:
  freesurfer: |
    your@email.com
    12345
     *key1
     key2
     key3
```
