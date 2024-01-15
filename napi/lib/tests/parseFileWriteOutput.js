const { parseFileWriteOutput } = require("../export");
const path = require("path");

const fs = require("fs");

describe("parseFileWriteSnippet tests: Input File -> Output File", () => {
  const fileName = "lib/tests/mock/test.txt";
  const outputFile = "lib/tests/mock/output.txt";
  test("testFunc, returns expected string", () => {
    const correctResult = parseFileWriteOutput(
      fileName,
      outputFile,
      `Snippet from ${fileName}`,
      "",
      "",
      true,
      true,
      false
    );

    expect(correctResult).toBe(0);
  });

  test("valid append to output file", () => {
    const correctAppend = parseFileWriteOutput(
      fileName,
      outputFile,
      `Snippet from ${fileName}`,
      "",
      "",
      true,
      true,
      false
    );

    expect(correctAppend).toBe(0);
  });

  test("invalid append to output file", () => {
    const invalidInput = parseFileWriteOutput(
      "notafile",
      outputFile,
      `Snippet from ${fileName}`,
      "",
      "",
      true,
      true,
      false
    );
    expect(invalidInput).toBe(1);
  });

  afterAll(() => {
    const filePath = path.join(outputFile);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  });
});
