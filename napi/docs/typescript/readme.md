# Adding typescript

Define exports in `lib/export.js` and types in `lib/export.d.ts` - and point **package.json** to `lib/export.d.ts`

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

- Create **export.d.ts**

```ts
declare module "vsfragments_node" {
  /**
   * Sample Method to Add two numbers together using the Foreign Function Interface
   * @param a - The first number.
   * @param b - The second number.
   * @returns The sum of `a` and `b`.
   */
  export function zigAdd(a: number, b: number): number;

  // other funcs
}
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
const addon = require("node-gyp-build")(__dirname);

// define exports matching .d.ts

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
