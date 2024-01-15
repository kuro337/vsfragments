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
