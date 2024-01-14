// ffi-esm.d.ts

declare module "ffi-esm" {
  interface Addon {
    /**
     * Sample Method to Add two numbers together using the Foreign Function Interface
     * @param a - The first number.
     * @param b - The second number.
     * @returns The sum of `a` and `b`.
     */
    zigAdd(a: number, b: number): number;

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
    getPath(filePath: string): string;

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
    createSnippetWithMetadata(
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
    parseFileWriteOutput(
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
    parseStringWriteToFile(
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
    convertDirToSnippet(dir_path: string, outputFile: string): number;

    writeFileCurrPath(filePath: string): number;
    writeFileToPathAbs(filePath: string): number;
    parseFileGetSnippet(filePath: string, print: boolean): string;

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
    parseStringFromNode(text: string): string;
  }

  const addon: Addon;

  export = addon;
}
