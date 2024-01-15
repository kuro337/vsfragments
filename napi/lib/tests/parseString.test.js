// needs to be near exports

const { parseStringFromNode } = require("../export");

describe("parseStringFromNode() Tests: Passing a String and Receiving the Snippet", () => {
  test("directResult returns expected string", () => {
    const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
    const directResult = parseStringFromNode(inputString);

    const expectedOutput =
      '\t"VSCode Code Snippet": {\n\t\t"prefix": "prefix_insertSnippet",\n\t\t"body": [\n\t\t\t"asdajsnd\\\\n\\\\\\\\\\\\nnnnasdkaskmaskdm"\n\t\t],\n\t\t"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."\n\t}\n';

    expect(directResult).toBe(expectedOutput);
    expect(compareStrings(directResult, expectedOutput)).toBe(true);
  });

  test("directResult length is greater than expected minimum", () => {
    const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
    const directResult = parseStringFromNode(inputString);

    const minLength = 10; // Set this to the minimum expected length
    expect(directResult.length).toBeGreaterThan(minLength);
  });

  test("directResult can be parsed into a JSON object", () => {
    const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
    const directResult = parseStringFromNode(inputString);

    let parsedObject;
    try {
      parsedObject = JSON.parse(`{${directResult}}`);
    } catch (error) {
      parsedObject = null;
    }

    expect(parsedObject).not.toBeNull();
  });
});

// helpers

function compareStrings(str1, str2, debug) {
  const maxLength = Math.max(str1.length, str2.length);

  for (let i = 0; i < maxLength; i++) {
    const char1 = str1.charCodeAt(i) || "N/A";
    const char2 = str2.charCodeAt(i) || "N/A";

    debug &&
      console.log(
        `Index ${i}: str1 CharCode = ${char1}, str2 CharCode = ${char2}`
      );

    if (char1 !== char2) {
      console.log(
        `Difference found at index ${i}:\nReturned:'${str1[i]}'\nFixCase:'${str2[i]}'`
      );

      const start = Math.max(0, i - 10);
      const end = Math.min(i + 10, maxLength);

      const beforeAfterStr1 = str1.substring(start, end);
      const beforeAfterStr2 = str2.substring(start, end);

      console.log(
        `CORRECT STRING around difference in str1: '${beforeAfterStr1}'`
      );
      console.log(
        `FIXTHIS STRING around difference in str2: '${beforeAfterStr2}'`
      );
      return false;
    }
  }
  return true;
}

function printStringWithEscapeSequences(str) {
  for (let i = 0; i < str.length; i++) {
    const char = str[i];
    let charToPrint = "";

    switch (char) {
      case "\n":
        charToPrint = "\\n";
        break;
      case "\t":
        charToPrint = "\\t";
        break;
      case "\r":
        charToPrint = "\\r";
        break;
      default:
        charToPrint = char;
    }

    process.stdout.write(charToPrint);
  }
  console.log(); // New line at the end
}

// printStringWithEscapeSequences(directResult);
