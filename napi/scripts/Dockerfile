# Pulls Latest Master Zig, Builds library, and creates linux node package

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache curl jq tar xz git

RUN ZIG_URL=$(curl -s https://ziglang.org/download/index.json | jq -r '.master."aarch64-linux".tarball') && \
  curl -L $ZIG_URL -o zigmaster.tar.xz

RUN mkdir zig-dist && \
  tar -xJf zigmaster.tar.xz -C zig-dist --strip-components=1 && \
  mv zig-dist/zig /usr/local/bin/ && \
  mv zig-dist/lib /usr/local/lib/zig && \
  rm -rf zig-dist zigmaster.tar.xz


RUN zig version || exit 1


RUN git clone https://github.com/kuro337/vsfragments.git && \
  cd vsfragments && \
  git pull


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






