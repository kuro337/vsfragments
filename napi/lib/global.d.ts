declare global {
  /// <reference path="./export.js" />

  // declare module "createSnippetWithMetadata" {
  //   /**
  //    * Transforms a File to a Snippet and writes to the location provided.
  //    * The output file can be an existing file or a new file.
  //    * @example
  //    *  createSnippetWithMetadata(
  //    *      "path/to/file.cc", "Reading bytes", "cpp_readBytes",
  //    *      "reading byte streams from disk",
  //    *      true, // create new file if not found
  //    *      true  // print to stdout
  //    * );
  //    *
  //    * @param filePath - The path to the folder.
  //    * @param title - The name of the output file, optionally a fully qualified path.
  //    * @param string - The name of the output file, optionally a fully qualified path.
  //    * @param description - The name of the output file, optionally a fully qualified path.
  //    * @param newFile - The name of the output file, optionally a fully qualified path.
  //    * @param printOut - The name of the output file, optionally a fully qualified path.
  //    * @returns A status code indicating success or failure.
  //    */
  //   function createSnippetWithMetadata(
  //     filePath: string,
  //     title: string,
  //     prefix: string,
  //     description: string,
  //     newFile: boolean,
  //     printOut: boolean
  //   ): string;

  //   export = createSnippetWithMetadata;
  // }

  // declare module "convertDirToSnippet" {
  //   /**
  //    * Creates a snippet file from a directory.
  //    *
  //    * The function processes all text files in the given directory and generates a snippet file.
  //    * Non-UTF files are ignored, making it safe to use in directories with binary files.
  //    *
  //    *  @example
  //    * convertDirToSnippet('/path/to/directory', 'output.snippets');
  //    *
  //    * @param dir_path - The path to the folder.
  //    * @param outputFile - The name of the output file, optionally a fully qualified path.
  //    * @returns A status code indicating success or failure.
  //    */
  //   function convertDirToSnippet(dir_path: string, outputFile: string): number;

  //   export = convertDirToSnippet;
  // }

  /**
   * Sample Method to Add two numbers together using the Foreign Function Interface
   * @param a - The first number.
   * @param b - The second number.
   * @returns The sum of `a` and `b`.
   */
  export default function zigAdd(a: number, b: number): number;

  /**
   * Return the absolute Path from a file path
   *  @example
   * const absolutePath = addon.getPath("");
   *
   * console.log(`${absolutePath}.txt`);
   *
   *  @param filePath - A path to a file.
   *
   * @returns The absolute file path
   */
  export default function getPath(filePath: string): string;

  /**
   * Transforms a File to a Snippet and writes to the location provided.
   * The output file can be an existing file or a new file.
   * @example
   *  createSnippetWithMetadata(
   *      "path/to/file.cc", "Reading bytes", "cpp_readBytes",
   *      "reading byte streams from disk",
   *      true, // create new file if not found
   *      true  // print to stdout
   * );
   *
   * @param filePath - The path to the folder.
   * @param title - The name of the output file, optionally a fully qualified path.
   * @param string - The name of the output file, optionally a fully qualified path.
   * @param description - The name of the output file, optionally a fully qualified path.
   * @param newFile - The name of the output file, optionally a fully qualified path.
   * @param printOut - The name of the output file, optionally a fully qualified path.
   * @returns A status code indicating success or failure.
   */
  export default function createSnippetWithMetadata(
    filePath: string,
    title: string,
    prefix: string,
    description: string,
    newFile: boolean,
    printOut: boolean
  ): string;

  /**
   * Transforms a File to a Snippet and writes to the location provided.
   * The output file can be an existing file or a new file.
   *
   * @param dir_path - The path to the folder.
   * @param outputFile - The name of the output file, optionally a fully qualified path.
   * @returns A status code indicating success or failure.
   */
  export default function parseFileWriteOutput(
    inputFilePath: string,
    outputFilePath: string,
    prefix: string,
    description: string,
    newFile: boolean,
    printOut: boolean
  ): number;

  /**
   * Transforms a String to a Snippet and writes to the location provided.
   * The output file can be an existing file or a new file.
   *
   * @example
   *
   * const multiLineString = `"  status = register_napi_function(env, exports, "parseStringWriteToFile", ZigParseStringWriteToFile);
   * if (status != napi_ok)
   * {
   * napi_throw_error(env, NULL, "Unable to register function for parseStringWriteToFile");
   * }"`;
   *
   *  parseStringWriteToFile(
   *      multiLineString,
   *      "snippet.json",
   *      "js_napiUsage",
   *      true,
   *      false
   * );
   *
   * @param text - The path to the folder.
   * @param outputFilePath - The name of the output file, optionally a fully qualified path.
   * @param prefix       - Prefix for Snippet trigger
   * @param description - Description for Snippet
   * @param newFile     - Creating a new file
   * @param printOut    - Print to stdout
   * @returns A status code indicating success or failure.
   */
  export default function parseStringWriteToFile(
    text: string,
    outputFilePath: string,
    prefix: string,
    description: string,
    newFile: boolean,
    printOut: boolean
  ): number;

  /**
   * Creates a snippet file from a directory.
   *
   * The function processes all text files in the given directory and generates a snippet file.
   * Non-UTF files are ignored, making it safe to use in directories with binary files.
   *
   *  @example
   * convertDirToSnippet('/path/to/directory', 'output.snippets');
   *
   * @param dir_path - The path to the folder.
   * @param outputFile - The name of the output file, optionally a fully qualified path.
   * @returns A status code indicating success or failure.
   */
  export default function convertDirToSnippet(
    dir_path: string,
    outputFile: string
  ): number;

  /**
   * Reads a File and returns the Snippet formed from it
   *
   * This snippet can be passed the  create  argument
   * If Passed: A full valid JSON Object is returned enclosed with { }
   * If Absent: The Snippet String is returned which represents an entry in a Snippets file
   *
   *  @example
   *  // get a snippet
   *  const snippet = parseFileGetSnippet(fileName, false, true);
   *
   *  // get a full Object which is a valid .code-snippets file
   *  const snippet = parseFileGetSnippet(fileName, true, true);
   *
   * @param filePath - The path to the file.
   * @param create -  True returns a new Snippets file, else returns a single Snippet entry
   * @param print -  Print output to stdouT
   * @returns The Snippet string
   */
  export default function parseFileGetSnippet(
    filePath: string,
    create: boolean,
    print: boolean
  ): string;

  /**
   * Pass a String from Node to FFI
   *
   * This method returns a string and transfers ownership of it to Node.
   *
   *  @example
   * const inputString = "asdajsnd\\n\\\\nnnnasdkaskmaskdm";
   * const directResult = parseStringFromNode(inputString);
   *
   * @param text - The String to be parsed into a Snippet.
   * @returns The parsed and formatted string with ASCII control characters.
   */
  export default function parseStringFromNode(text: string): string;

  export default function writeFileCurrPath(filePath: string): number;
  export default function writeFileToPathAbs(filePath: string): number;
}
