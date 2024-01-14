FROM alpine:latest

WORKDIR /app

RUN apk upgrade && apk update

RUN apk add --no-cache \
  build-base \
  curl \
  git \
  linux-headers \
  npm \
  py3-pip \
  python3 \
  python3-dev \
  sqlite \
  libffi-dev \
  nodejs 


# RUN npm install --save node-gyp-build
# RUN npm install -g prebuildify
# RUN npm install -g node-gyp

# COPY . ./

# npm i
# prebuildify --napi
# node export.js

# Files Required to build

# binding.gyp   package.json (points to c files and static libs)
# export.js ffi-esm.d.ts 
# src (3 c files) 
# static 2 static libs