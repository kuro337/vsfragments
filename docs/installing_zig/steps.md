# installing zig

```bash

brew install zig  # unix

choco install zig # win

```

<br/>

That should be it!

<br/>

```bash

zig version 

```

<br/>

## Building Zig from Source

<br/>

Building the entire toolchain from source is also very straightforward. 

<br/>

**LLVM** is the only main dependency so the toolchain should already exist on most systems.

<br/>

the advantage of using **LLVM** directly is being able to compile to **WASM**  and **C**  directly

<br/>

**System Prereqs**

```bash
# confirm 
brew install llvm
brew install cmake
brew install zstd
brew install mysql
brew install openssl
```


<br/>

Steps to build the compiler which is the only dependency required to build for any platform



<br/>


```bash
git clone git@github.com:ziglang/zig.git

cd zig
mkdir build
cd build

# for windows and linux
cmake ..

# for macos
cmake .. -DZIG_STATIC_LLVM=ON -DCMAKE_PREFIX_PATH="$(brew --prefix llvm);$(brew --prefix zstd)"

make install

# binary in stage3/bin/zig

cd stage3/bin

zig version # 0.12.0-dev.1856+94c63f31f (latest master)

```

<br/>

Official Docs https://github.com/ziglang/zig
