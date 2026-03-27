# CiCLONE

## License

CiCLONE uses FreeSurfer internally and requires a FreeSurfer license.
The license is injected via environment variable by the workbench-operator, using the same
`freesurfer` secret key as FreeSurfer. The `.bash_profile` writes it to `$HOME/license.txt` at startup.

To request a license: https://surfer.nmr.mgh.harvard.edu/registration.html
