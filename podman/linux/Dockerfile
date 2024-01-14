FROM alpine:latest

WORKDIR /app

COPY build.zig /app/

RUN apk add --no-cache xz tar git 

# COPY prebuilt/zig-linux-aarch64-0.12.0-dev.1879+e19219fa0.tar.xz /app/

COPY zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz /app/
RUN tar -xvf /app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz  -C /app/
ENV PATH="${PATH}:/app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0"

RUN rm /app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz

RUN git clone https://github.com/kuro337/vsfragments.git

# podman build -t zig-container .
# podman run  -it --rm --name zig-instance zig-container
# podman exec -it zig-instance sh




# curl -O https://ziglang.org/builds/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz

# https://ziglang.org/download/index.json

