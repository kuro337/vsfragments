# Adding typescript

- Currently there is a `package.json` and `export.js`

```json
{
  "name": "ffi-esm",
  "version": "0.0.1",
  "main": "export.js",
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
    "src/",
    "lib/"
  ]
}
```

- Create a typings file and specify in `package.json` we need to have types

```json
"types": "ffi-esm.d.ts",
```
