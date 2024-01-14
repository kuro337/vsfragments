# Building to use in other projects

## Correct Solution is `prebuildify` + `node-gyp-build`

- They recommend https://github.com/prebuild/prebuildify

- https://github.com/prebuild/node-gyp-build

- Consider https://nodejs.github.io/node-addon-examples/build-tools/node-pre-gyp additionally to use with this

## Build

```bash
npm i # installs C packaGe and creates core node file at build/Release/zig_core

# Create a file export.js that acts as an interface between it

# exports.js :

const addon = require("./build/Release/zig_core");

module.exports = {
  receiveStringFromJS: addon.receiveStringFromJS,
  parseStringFromJS: addon.parseStringFromJS,
};



```

- `package.json` : Specify `export.js` as main

```json
{
  "name": "ffi-esm",
  "version": "1.0.0",
  "main": "export.js",
  "gypfile": true,
  "scripts": {
    "install": "node-gyp rebuild"
  },
  "dependencies": {
    "node-addon-api": "^3.0.0"
  }
}
```

- Run `npm link` at same level of package.json to create a global link

- In a new project -

```bash
npm init -y
npm link ffi-esm # from okg.json

# from package we linked to remove
npm unlink --global

# should create node_modules
```

- Run app should work

```js
const { receiveStringFromJS, parseStringFromJS } = require("ffi-esm");

const inputString = "example string";
const result = receiveStringFromJS(inputString);

// node test.js
```

```bash
npm install
npm link
npm unlink


# In the extension
npm link ffi-esm

# To unlink
npm unlink ffi-module


```

# Checking Links

```bash

npm list -g --depth=0

/opt/homebrew/lib
├── ffi-esm@1.0.0 -> ./../../../Code/JS/FFI/zig_c_napi/ffi
├── generator-napi-module@0.3.0
├── npm@10.2.4
└── vsce@2.15.0

# Global Node modules

npm list -g --depth=0

npm root -g

cd $(npm root -g)
rm -rf ffi-esm

```
