# System Patterns

This document describes the system architecture, key technical decisions, and design patterns used in the CHORUS project.

## Containerization and Startup

The entire CHORUS platform is container-based, with each application running in its own Docker container. There is a standardized startup sequence for all application containers.

### Docker Entrypoint
A common `docker-entrypoint.sh` script is used as the `ENTRYPOINT` for all application containers. This script is responsible for:

1.  **Configuration**: Executing any shell scripts (`.sh`) or sourcing environment variable files (`.envsh`) found in the `/docker-entrypoint.d/` directory. Scripts are executed in lexicographical order, and numbering is used to enforce a specific execution sequence (e.g., `1-create-user.sh`, `2-copy-config.sh`).
2.  **User Creation**: The `1-create-user.sh` script creates a non-root user, typically `chorus`, to run the application.
3.  **Application Execution**: The main application command, defined by the `APP_CMD` environment variable, is executed as the `chorus` user.
4.  **GPU Acceleration**: The entrypoint script checks for a `CARD` environment variable to enable `vglrun` for applications that require GPU acceleration.

This pattern ensures a consistent and configurable environment for all applications in the suite. 