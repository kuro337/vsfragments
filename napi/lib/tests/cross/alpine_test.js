const {
  getPath,
  convertDirToSnippet,
  parseStringFromNode,
} = require("vsfragments_node");

const inputString = "example string";

const directResult = parseStringFromNode(inputString);
console.log(`Passing JS String Directly Worked.\n${directResult}`);

const z = getPath("test.js");
console.log(z);

console.log("Alpine Test Successful");

// func calls
//const num_files_converted_a = convertDirToSnippet(dir_path, output_file);

//console.log("Converted ", num_files_converted_a);
// testing parseStringFromJS -> parseStringFromNode
