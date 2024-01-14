# npm

Create **package.json**

define **files** to include in package

_`note`:Overrides ignores in .npmignore_

```json
{
  "name": "ffi-esm",
  "version": "0.0.3",
  "main": "lib/export.js",
  "types": "lib/ffi-esm.d.ts",
  "gypfile": true,
  "scripts": {
    "install": "node-gyp-build"
  },
  "dependencies": {
    "node-addon-api": "^3.0.0",
    "node-gyp-build": "^4.8.0"
  },
  "files": [
    "export.js",
    "prebuilds/",
    "README.md",
    "binding.gyp",
    "src/**/*",
    "!src/**/zig-cache/",
    "!src/**/zig-out/",
    "lib"
  ]
}
```

<br>

Include **.npmignore** for files to ignore

```bash

node_modules/
pkgjson.copy
build/Release/
zig-out/
zig-cache/
build/
docs/
src/native/zig/zig_fn/zig-out/
src/native/zig/zig_fn/zig-cache/
tests/
package-lock.json

```

<br>

View **Tarball**

```bash
npm pack

# viewing a tarball of package uploaded

====================================
npm notice
npm notice 📦  ffi-esm@0.0.3
npm notice === Tarball Contents ===
npm notice 445B    README.md
npm notice 794B    binding.gyp
npm notice 421B    export.js
npm notice 421B    lib/export.js
npm notice 1.3kB   lib/ffi-esm.d.ts
npm notice 428B    package.json
npm notice 283.7kB prebuilds/darwin-arm64/ffi-esm.node
npm notice 12.6kB  src/native/c/napi_core.c
npm notice 599B    src/native/c/napi_core.h
npm notice 8.3kB   src/native/c/zig_core.c
npm notice 3.5kB   src/native/zig/zig_fn/build.zig
npm notice 8.1kB   src/native/zig/zig_fn/funcs.zig
npm notice === Tarball Details ===
npm notice name:          ffi-esm
npm notice version:       0.0.3
npm notice filename:      ffi-esm-0.0.3.tgz
npm notice package size:  117.8 kB
npm notice unpacked size: 320.6 kB
npm notice shasum:        c77f36f48a4bb4cd8e13816b11462139d2a74ccc
npm notice integrity:     sha512-0vMLoRMjwIsYw[...]udpI3YytT+wJQ==
npm notice total files:   12
npm notice
ffi-esm-0.0.3.tgz
====================================
```

<br>

**Publish** module

```bash
npm publish
```

<br>

**Install** and **Use**

```bash
# install package
npm i ffi-esm

# install/upgrade to latest
npm i ffi-esm@latest
```
