# builds library and creates linux node package

FROM alpine:latest

WORKDIR /app


RUN apk add --no-cache xz tar git curl 

RUN git clone https://github.com/kuro337/vsfragments.git && \
  cd vsfragments && \
  git pull



# Download the Zig compiler tarball
RUN curl https://ziglang.org/builds/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz -o zigmaster.tar.xz

# Extract the tarball to /app/
RUN tar -xvf zigmaster.tar.xz -C /app/

# Add Zig to PATH
ENV PATH="/app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0:${PATH}"

# Remove the downloaded tarball
RUN rm zigmaster.tar.xz

RUN zig version

RUN git clone https://github.com/Hejsil/zig-clap.git && \
  cd zig-clap && \
  git pull


RUN cd /app/vsfragments/c_exports && zig build 

# copy libs to napi folder

RUN mkdir -p /app/vsfragments/napi/static/lib/
RUN mkdir -p /app/vsfragments/napi/static/lib/

RUN cp -u /app/vsfragments/c_exports/zig-out/lib/native/ReleaseFast/* /app/vsfragments/napi/static/lib/

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

RUN npm cache clean -f

RUN cd /app/vsfragments/napi && \
  npm install -g prebuildify && \
  npm i && \ 
  prebuildify --napi && \
  prebuildify --napi --out lib && \
  npm test


# podman build -t zig-container . --no-cache

# podman run  -it --rm --name zig-instance zig-container






