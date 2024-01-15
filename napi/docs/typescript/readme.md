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

- Adding Typescript

```
npm install typescript --save-dev


```

**export.d.ts**

```ts
/// <reference path="./export.js" />

/**
 * Sample Method to Add two numbers together using the Foreign Function Interface
 * @param a - The first number.
 * @param b - The second number.
 * @returns The sum of `a` and `b`.
 */
export function zigAdd(a: number, b: number): number;
```

**export.js**

```js
/// <reference path="./export.d.ts" />

const addon = require("node-gyp-build")(__dirname);

module.exports = {
  createSnippetWithMetadata: addon.createSnippetWithMetadata,

  convertDirToSnippet: addon.convertDirToSnippet,
  parseFileGetSnippet: addon.parseFileGetSnippet,
  parseFileWriteOutput: addon.parseFileWriteOutput,
  parseStringWriteToFile: addon.parseStringWriteToFile,
  parseStringFromNode: addon.parseStringFromNode,
  getPath: addon.getPath,
};
```

Now when we use our functions they have types

```js
// has types and jsdoc info

const { parseFileWriteOutput } = require("../export");
```
