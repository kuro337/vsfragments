const addon = require("node-gyp-build")(__dirname);

// console.log(__dirname);
// console.log("Addon loaded:", addon); // This logs the loaded addon object

module.exports = {
  createSnippetWithMetadata: addon.createSnippetWithMetadata,

  convertDirToSnippet: addon.convertDirToSnippet,
  parseFileGetSnippet: addon.parseFileGetSnippet,
  parseFileWriteOutput: addon.parseFileWriteOutput,
  parseStringWriteToFile: addon.parseStringWriteToFile,
  parseStringFromNode: addon.parseStringFromNode,
  getPath: addon.getPath,
};

function testOne() {
  const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
  const directResult = addon.parseStringFromNode(inputString);

  const expectedOutput =
    '\t"VSCode Code Snippet": {\n\t\t"prefix": "prefix_insertSnippet",\n\t\t"body": [\n\t\t\t"asdajsnd\\\\n\\\\\\\\\\\\nnnnasdkaskmaskdm"\n\t\t],\n\t\t"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."\n\t}\n';

  if (directResult === expectedOutput) console.log("EQUAL");
}

testOne();
