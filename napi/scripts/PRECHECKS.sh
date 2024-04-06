#!/bin/bash

set -e

echo "Checking npm login status..."
npm whoami &> /dev/null && echo "npm login status verified." || { echo "Not logged in to npm. Please run 'npm login'."; exit 1; }

echo "Verifying Podman installation..."
command -v podman &> /dev/null && echo "Podman installation verified. $(podman --version)" || { echo "Podman is not installed. Please install Podman first."; exit 1; }

echo "Ensuring Podman machine is ready..."
if podman machine inspect podman-machine-default &> /dev/null; then
    echo "Podman machine 'podman-machine-default' exists. Ensuring it's running..."
    podman machine start podman-machine-default || { echo "Podman machine is already running or encountered an error starting."; }
else
    echo "Initializing and starting Podman machine 'podman-machine-default'..."
    podman machine init && podman machine start podman-machine-default
fi

echo "Podman machine is ready for use."
echo "All setup checks passed successfully."
