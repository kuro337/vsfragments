# Setup Container with Zig

- Easiest Way is to setup the Prebuilt binaries onto the container

```bash
# Contains Download Links of .xz files
https://ziglang.org/download/index.json
# tar -xvf to unzip

curl  https://ziglang.org/builds/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz

curl -O https://ziglang.org/builds/zig-linux-aarch64-0.12.0-dev.2154+e5dc9b1d0.tar.xz


```

```bash
git clone git@github.com:ziglang/zig.git

mkdir build
cd build
cmake ..
make install

```
