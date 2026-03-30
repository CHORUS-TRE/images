# Freesurfer

## License

The license is injected via environment variable by the workbench-operator.
The operator reads from a Kubernetes Secret (configured via `--license-secret-name`) and sets
`FREESURFER_LICENSE` from the `freesurfer` key. The `.bash_profile` writes it to `$HOME/license.txt` at startup.

To request a license: https://surfer.nmr.mgh.harvard.edu/registration.html

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
