#!/bin/bash

IMAGE="linux_napi"
CONTAINER="linux_pod"
SRC_PATH_A="/app/vsfragments/napi/prebuilds"
SRC_PATH_B="/app/vsfragments/napi/lib/prebuilds"
DEST_PATH_A="../lib/prebuilds"
DEST_PATH_B="../prebuilds"

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