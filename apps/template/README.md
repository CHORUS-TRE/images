# Template Application

This directory serves as a template for creating new Chorus-compatible application images.

## Purpose

Use this template as a starting point for packaging a new application. It includes the standard file structure and conventions used in this repository.

## Files

-   `Dockerfile`: A well-commented, multi-stage Dockerfile that follows best practices for security and efficiency.
-   `build.sh`: A robust build script that handles versioning, caching, and publishing, consistent with other applications in the project.
-   `README.md`: This file.

## How to Use

1.  **Copy the Directory**: Copy the entire `template` directory to a new directory named after your application (e.g., `apps/my-new-app`).
2.  **Update `build.sh`**:
    -   Change `APP_NAME` to your application's name.
    -   Set the correct `APP_VERSION`.
3.  **Customize `Dockerfile`**:
    -   Fill in the placeholder sections in the `builder` stage to download and build your application's source code.
    -   Add any necessary runtime dependencies to the `final` stage.
    -   Copy the built application artifacts from the `builder` stage to the `final` stage.
    -   Update the `ENV` variables, especially `APP_CMD` (the command to start your app) and `APP_DATA_DIR_ARRAY` (directories to persist in the user's home).
    -   (Optional) Rename the default `appuser` to something more specific to your application (e.g., `vscode`, `rstudio`).
4.  **Build the Image**: Run the `build.sh` script from your new application directory.

    ```bash
    cd apps/my-new-app
    ./build.sh
    ```

5.  **Test**: Test the image thoroughly, ensuring it runs correctly as a non-root user and that data persistence works as expected.
