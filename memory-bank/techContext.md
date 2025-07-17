# Tech Context

This document outlines the technologies, development setup, technical constraints, and dependencies of the CHORUS project.

## Technologies Used

The CHORUS platform is built on a containerized architecture, with individual applications running in their own Docker containers.

### Core Technologies
- **Containerization**: Docker
- **Operating System**: The primary operating system for the application containers is Ubuntu (initially identified version 24.04).
- **Orchestration/Scripting**: Shell scripts (`bash`) are used extensively for building images and for container entrypoints.

### Application-Specific Technologies

#### `chorus-assistant`
- **Language**: Python 3
- **Web UI**: `open-webui`
- **LLM Runtime**: `ollama`
- **Browser**: `firefox-esr` 