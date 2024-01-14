#!/bin/bash

set -e

./BUILD_FULL_NATIVE.sh 
./PREBUILT.sh 
./PUSH_LIB.sh 
