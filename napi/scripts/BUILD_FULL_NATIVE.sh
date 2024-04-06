#!/bin/bash

echo -e "Building FFI Consumer Node Lib for Native Target"

SCRIPT_DIR=$(pwd)

echo -e "Deleting package.lock & node_modules\n"

rm -rf ../package-lock.json ../node_modules 

echo -e "building static libraries\n"

cd ../../c_exports/
zig2 build --summary all

mkdir -p ../napi/static/lib

echo -e "Copying Artifacts\n"

# Copy files to the destination directory
cp -rf zig-out/lib/native/ReleaseFast/* ../napi/static/lib/

# Change to the napi directory
cd ../napi

echo -e "Building Package and running Tests\n"

npm i
prebuildify --napi --out lib
prebuildify --napi 
npm test
