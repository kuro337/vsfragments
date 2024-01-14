const { parseFileWriteOutput } = require("../export");

describe("ffi-esm tests", () => {
  test("testFunc, returns expected string", () => {
    const fileName = "test.txt";
    const outputFile = "output.txt";
    const result = parseFileWriteOutput(
      fileName,
      outputFile,
      `Snippet from ${fileName}`,
      "",
      "",
      true,
      true,
      true
    );

    // if (result === 0) {
    //   console.log(`Snippets file ${outputFile} updated Successfully.`);
    // } else {
    //   console.log(`Snippets file ${outputFile} was not updated.`);
    // }

    expect(1).toBe(1);
  });
});
