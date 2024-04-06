#!/bin/bash

set -e

./PRECHECKS.sh
echo -e "Validated Podman Machine Health and npm registry validation"


echo -e "Building Native Extern Zig FFI Lib and Node Package"
./BUILD_FULL_NATIVE.sh 

echo -e "Building Portable Target Prebuilds for FFI Consumers"
./PREBUILT.sh 


echo -e "Running Tests, Pushing Package to npm Registry, and Updating CHANGELOG"
./PUSH_LIB.sh 


echo -e "Successfully Built all Targets and Published to npm"
