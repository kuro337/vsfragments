FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache xz tar

COPY prebuilt/zig-linux-aarch64-0.12.0-dev.1879+e19219fa0.tar.xz /app/

# Stage linux arm binaries
# COPY binaries/* /app/

RUN tar -xvf /app/zig-linux-aarch64-0.12.0-dev.1879+e19219fa0.tar.xz -C /app/

ENV PATH="${PATH}:/app/zig-linux-aarch64-0.12.0-dev.1879+e19219fa0"

RUN rm /app/zig-linux-aarch64-0.12.0-dev.1879+e19219fa0.tar.xz

# podman build -t zig-container .
# podman run  -it --rm --name zig-instance zig-container
# podman exec -it zig-instance sh
