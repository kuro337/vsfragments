const { parseFileGetSnippet } = require("../export");
const fs = require("fs");
const path = require("path");

describe("parseFileGetSnippet() tests ", () => {
  const fileName = "lib/tests/mock/mock_code.md";

  test("parseFileGetSnippet, returns expected string", () => {
    const snippet = parseFileGetSnippet(fileName, true, false);

    expect(snippet.length).toBeGreaterThan(150);
    expect(snippet.length).toBe(5593);
  });

  test("parseFileGetSnippet with create flag false", () => {
    const snippet = parseFileGetSnippet(fileName, false, false);

    expect(snippet.length).toBeGreaterThan(5000);
    expect(snippet.length).toBe(5589);
  });

  test("Validate Snippet non create Flag Valid JSON and Structure", () => {
    const snippet = parseFileGetSnippet(fileName, false, false);

    let parsedObject;
    try {
      parsedObject = JSON.parse(`{${snippet}}`);
    } catch (error) {
      console.error("Parsing Error:", error);
      parsedObject = null;
    }

    expect(parsedObject).not.toBeNull();

    expect(parsedObject).toHaveProperty("VSCode Code Snippet");

    const snippetData = parsedObject["VSCode Code Snippet"];
    expect(snippetData).toHaveProperty("prefix");
    expect(snippetData.prefix).toBe("prefix_insertSnippet");

    expect(snippetData).toHaveProperty("body");
    expect(Array.isArray(snippetData.body)).toBe(true);
    expect(snippetData.body.length).toBeGreaterThan(10);

    expect(snippetData.body.length).toBe(147);

    expect(snippetData.body[0]).toBe(`/// <reference path="./export.js" />`);
  });

  test("Validate Snippet Convert Valid JSON and Structure", () => {
    const snippet = parseFileGetSnippet(fileName, true, false);

    let parsedObject;
    try {
      parsedObject = JSON.parse(snippet);
    } catch (error) {
      console.error("Parsing Error:", error);
      parsedObject = null;
    }

    expect(parsedObject).not.toBeNull();

    expect(parsedObject).toHaveProperty("VSCode Code Snippet");

    const snippetData = parsedObject["VSCode Code Snippet"];
    expect(snippetData).toHaveProperty("prefix");
    expect(snippetData.prefix).toBe("prefix_insertSnippet");

    expect(snippetData).toHaveProperty("body");
    expect(Array.isArray(snippetData.body)).toBe(true);
    expect(snippetData.body.length).toBeGreaterThan(10);

    expect(snippetData.body.length).toBe(147);

    expect(snippetData.body[0]).toBe(`/// <reference path="./export.js" />`);
  });
});
