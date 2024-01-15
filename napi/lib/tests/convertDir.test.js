const { convertDirToSnippet } = require("../export");
const path = require("path");

const fs = require("fs");

describe("convertDirToSnippet tests: Input Directory to Snippet", () => {
  const fileName = "lib/tests/cross";
  const outputFile = "lib/tests/mock/dir.code-snippets";
  test("testFunc, returns expected string", () => {
    const correctResult = convertDirToSnippet(fileName, outputFile);

    expect(correctResult).toBe(2);
  });

  test("Validate Dir Convert Valid JSON", () => {
    // Read the contents of the output file
    const fileContents = fs.readFileSync(outputFile, "utf8");
    let parsedObject;

    try {
      // Try parsing the file contents as JSON
      parsedObject = JSON.parse(fileContents);
    } catch (error) {
      console.error("Parsing Error:", error);
      parsedObject = null;
    }

    expect(parsedObject).not.toBeNull();
  });

  afterAll(() => {
    const filePath = path.join(outputFile);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  });
});
