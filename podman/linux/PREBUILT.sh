#!/bin/bash

IMAGE="linux_napi"
CONTAINER="linux_pod"
CONTAINER_PATH="/app/vsfragments/napi/lib/prebuilds"
DEST_PATH="../../napi/lib/prebuilds"

# run build container
podman build -t $IMAGE .  --no-cache
podman run --name $CONTAINER $IMAGE 

# Create the destination directory if it does not exist
mkdir -p "$DEST_PATH"

# Copy the contents of the folder from the container to dest outside container
podman cp "$CONTAINER:$CONTAINER_PATH/." "$DEST_PATH"

echo "Folder copied to $DEST_PATH"

# cleanup
podman stop $CONTAINER
podman rm $CONTAINER

echo "$CONTAINER shut down"