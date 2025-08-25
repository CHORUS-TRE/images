# Project Brief: CHORUS

## Overview

CHORUS is a containerized, extensible platform that provides a suite of tools for scientific research, with a strong focus on medical and neuroscience applications. It appears to be a Trusted Research Environment (TRE) designed to provide researchers with a secure and reproducible environment for data analysis and collaboration.

## Core Components

The platform is composed of several independent applications, each packaged as a Docker container. These applications include:

-   **Development Environments**: `jupyterlab`, `rstudio`, `vscode`
-   **Neuroimaging Tools**: `freesurfer`, `fsl`, `itksnap`, `bidsificator`
-   **AI/ML Tools**: `chorus-assistant` (with `ollama`), `meditron`
-   **Data Analysis and Visualization**: `grist`, `arx`, `localizer`
-   **Utility/Core Services**: A core set of scripts for container orchestration and a server component.

## Goals

Based on the architecture and toolset, the primary goals of the CHORUS project are likely:

1.  **To provide a secure and isolated environment** for sensitive research data.
2.  **To offer a wide range of pre-configured tools** for scientific research, reducing setup and configuration overhead for researchers.
3.  **To ensure reproducibility** of research by using containerized and version-controlled environments.
4.  **To support modern AI/ML workflows** alongside traditional scientific analysis tools. 