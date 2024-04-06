#!/bin/bash

echo -e "Creating Linux Images for FFI Consumer" 

IMAGE="linux_napi"
CONTAINER="linux_pod"
SRC_PATH_A="/app/vsfragments/napi/prebuilds"
SRC_PATH_B="/app/vsfragments/napi/lib/prebuilds"
DEST_PATH_A="../lib/prebuilds"
DEST_PATH_B="../prebuilds"

MACHINE_NAME="podman-machine-default"  
MAX_ATTEMPTS=5

# Function to check if Podman machine is running
function is_podman_machine_running() {
    podman machine list | grep -q "$MACHINE_NAME.*Running"
}

# Function to start Podman machine and wait for it to run
function start_podman_machine() {
    podman machine start $MACHINE_NAME
    for (( i=0; i<MAX_ATTEMPTS; i++ )); do
        if is_podman_machine_running; then
            echo "Podman machine $MACHINE_NAME started successfully."
            return 0
        fi
        echo "Waiting for Podman machine $MACHINE_NAME to start..."
        sleep 10
    done
    echo "Podman machine $MACHINE_NAME failed to start."
    return 1
}

# Check if Podman machine is running, if not, try to start it
if ! is_podman_machine_running; then
    echo "Starting Podman machine $MACHINE_NAME..."
    podman machine start $MACHINE_NAME
else
    echo "Podman machine $MACHINE_NAME is already running."
fi


# run build container
podman build -t $IMAGE .  --no-cache
podman run --name $CONTAINER $IMAGE 

# Create the destination directory if it does not exist
mkdir -p "$DEST_PATH_A"
mkdir -p "$DEST_PATH_B"

# Copy the contents of the folder from the container to dest outside container
podman cp "$CONTAINER:$SRC_PATH_A/." "$DEST_PATH_A"
podman cp "$CONTAINER:$SRC_PATH_A/." "$DEST_PATH_B"
podman cp "$CONTAINER:$SRC_PATH_B/." "$DEST_PATH_A"
podman cp "$CONTAINER:$SRC_PATH_B/." "$DEST_PATH_B"

echo "Folder copied to $DEST_PATH_A"
echo "Folder copied to $DEST_PATH_B"

# cleanup
podman stop $CONTAINER
podman rm $CONTAINER

echo "$CONTAINER shut down"