#!/bin/bash

cd ../..

zig2 build --summary all

sudo mv zig-out/bin/macos/aarch64/ReleaseFast/vsfragment /usr/local/bin/vsfragment

