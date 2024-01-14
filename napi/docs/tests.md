# Tests

```bash
npm install --save-dev jest @types/jest

# add jest as a test runner in pkg.json

{
  "scripts": {
    "test": "jest"
  },
  "jest": {
    "testEnvironment": "node"
  }
}


```

- Write Tests

```js
// lib/tests/parseString.test.js

const { receiveStringFromJS, parseStringFromNode } = require("ffi-esm");

describe("ffi-esm tests", () => {
  test("parseStringFromNode returns 0 on success", () => {
    const inputString = "some test string";
    const result = parseStringFromNode(inputString);
    expect(result).toBe(0);
  });

  test("directResult returns expected string", () => {
    const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
    const expectedOutput = "expected output"; // Replace with actual expected output
    const directResult = receiveStringFromJS(inputString);
    expect(directResult).toBe(expectedOutput);
  });
});
```
