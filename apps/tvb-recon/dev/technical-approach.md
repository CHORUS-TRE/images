
---
## Technical Approach

*   **Base Image:** Use `ubuntu:24.04` as the base image for consistency with other applications.
*   **Arguments:** Accept `APP_NAME` and `APP_VERSION` arguments for configuration and versioning.
*   **System Dependencies:**
    *   Install essential build tools (`git`, `build-essential`, etc.) and Python.
    *   Install FSL, FreeSurfer, and MRtrix3.
*   **Python Environment:**
    *   Install Miniforge3 to manage Python dependencies in an isolated environment.
    *   Create a dedicated conda environment for `tvb-recon`.
*   **Application Code:** Dynamically download the `tvb-recon` source code from the `main` branch of its GitHub repository (https://github.com/the-virtual-brain/tvb-recon).
*   **Chorus Integration:** Include standard Chorus scripts for `docker-entrypoint.sh` and utilities.
*   **Security:** Create and use a non-root user (`tvb`) for running the application.
*   **Multi-stage Build:** Use a multi-stage build to separate the build environment from the runtime environment, resulting in a smaller and more secure final image.
