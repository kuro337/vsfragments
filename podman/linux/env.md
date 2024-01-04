# Setup Container with Zig

- Easiest Way is to setup the Prebuilt binaries onto the container

```bash
# Contains Download Links of .xz files
https://ziglang.org/download/index.json
# tar -xvf to unzip

```

```bash
git clone git@github.com:ziglang/zig.git

mkdir build
cd build
cmake ..
make install

```