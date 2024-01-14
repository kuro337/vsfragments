# Prebuild

Get Static Libs, Clean Node Modules, Compile Node Lib, Check Package, Increment Version, and Publish

```bash
./BUILD_LIB_PKG.sh

```

# Clean Build

```bash
rm -rf node_modules
rm package-lock.json

# prebuild binaries so when users run npm i - first checks for prebuilds
prebuildify --napi

# install and then test in a new project
npm install

```

```bash
https://www.npmjs.com/package/node-gyp

Use prebuildify to create prebuilt packages

- They recommend https://github.com/prebuild/prebuildify

- https://github.com/prebuild/node-gyp-build

```

- Using prebuildify

```bash
npm install -g prebuildify
npm install -g node-gyp


prebuildify --all --strip

prebuildify --napi # generates in curr location - we want it to be where we use it



# Run this to create prebuilt binaries
prebuildify --napi

# Now making modules use prebuilds
npm install --save node-gyp-build


# Then add node-gyp-build as an install script to your module's package.json:
# replacing "install": "node-gyp rebuild"

{
  "name": "your-native-module",
  "scripts": {
    "install": "node-gyp-build"
  }
}

```

- `export.js`

```js
// package.json
{
  "name": "ffi-esm",
  "version": "1.0.0",
  "main": "export.js",
  "gypfile": true,
  "scripts": {
    "install": "node-gyp-build"
  },
  "dependencies": {
    "node-addon-api": "^3.0.0",
    "node-gyp-build": "^4.8.0"
  }
}

// export.js
const addon = require("node-gyp-build")(__dirname);

module.exports = {
  createSnippetWithMetadata: addon.createSnippetWithMetadata,
  convertDirToSnippet: addon.convertDirToSnippet,
  parseFileGetSnippet: addon.parseFileGetSnippet,
  parseFileWriteOutput: addon.parseFileWriteOutput,
  parseStringWriteToFile: addon.parseStringWriteToFile,
  parseStringFromJS: addon.parseStringFromJS,
};
```

- build

```bash
npm install

```

# Clean Build

```bash
rm -rf node_modules
rm package-lock.json

# prebuild binaries so when users run npm i - first checks for prebuilds
npm install --save node-gyp-build
prebuildify --napi --out lib



# IMPORTANT - prebuilds folder must be next to export.js

# install and then test in a new project
npm install


```
