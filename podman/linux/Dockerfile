# builds library and creates linux node package

FROM alpine:latest

WORKDIR /app

COPY build.zig /app/

RUN apk add --no-cache xz tar git 

RUN git clone https://github.com/kuro337/vsfragments.git && \
  cd vsfragments && \
  git pull

RUN rm -rf /app/vsfragments/build.zig 
RUN mv build.zig /app/vsfragments/


COPY zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz /app/
RUN tar -xvf /app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz  -C /app/
ENV PATH="${PATH}:/app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0"

RUN rm /app/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz

RUN git clone https://github.com/Hejsil/zig-clap.git && \
  cd zig-clap && \
  git pull


RUN cd /app/vsfragments/c_exports && zig build 

# copy libs to napi folder

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






