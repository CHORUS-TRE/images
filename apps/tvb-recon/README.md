# TVB-Recon

This application provides the TVB-Recon pipeline, a solution to build full brain network models starting from standard structural MR scans.

The pipeline preprocesses MR scans (T1 and DWI) to generate files that are compatible with The Virtual Brain (TVB). The resulting models can be uploaded into TVB or used independently for brain network modeling.

It uses the [Pegasus Workflow Management System](https://pegasus.isi.edu/) to connect and automate the various processing steps, which rely on tools like Freesurfer, FSL, and MRtrix3.
