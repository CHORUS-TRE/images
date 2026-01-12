# This script is executed for interactive shell sessions.
# It sets up the environment required by the application.

# Source the user-provided environment file if it exists.
if [ -s "/apps/app-name/config/.env" ]; then
    . "/apps/app-name/config/.env"
fi

# --- Application Environment Setup ---
# Add any application-specific environment setup here.
# For example, sourcing a setup script or setting environment variables.

# Example: Add a tool to the PATH
# export PATH="/opt/my-tool/bin:${PATH}"

# Example: Use a variable from the .env file
# if [ -n "$MY_APP_LICENSE" ]; then
#     echo "License found and configured."
#     # Logic to write the license to a file could go here.
# fi

# --- Final PATH Configuration ---
# Ensure all necessary paths are set correctly.
# export PATH=...

echo "Template application environment loaded."
