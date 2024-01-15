declare module "vsfragments_node" {
  /**
   * Sample Method to Add two numbers together using the Foreign Function Interface
   * @param a - The first number.
   * @param b - The second number.
   * @returns The sum of `a` and `b`.
   */
  export function zigAdd(a: number, b: number): number;

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
  export function getPath(filePath: string): string;

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
   * @param title   - Snippet Title Field
   * @param prefix - Snippet prefix to trigger in the IDE
   * @param description - Short useful description for the Snippet
   * @param enclosing_brackets - True returns a new Snippets file, else returns a single Snippet entry
   * @param print - Print to stdout if true
   * @returns - Returns the Snippet string
   */
  export function createSnippetWithMetadata(
    filePath: string,
    title: string,
    prefix: string,
    description: string,
    enclosing_brackets: boolean,
    printOut: boolean
  ): string;

  /**
   * Transforms a String to a Snippet and writes to the location provided.
   * The output file can be an existing file or a new file.
   *
   * @example
   *
   * const input_file = "path/to/some/file.txt"
   *
   *  parseFileWriteOutput(
   *      input_file,
   *      "snippet.json",
   *      "js_napiUsage",
   *      true,
   *      false
   * );
   *
   * @param inputFilePath - The input file - pass the full qualified Path
   * @param outputFilePath - The name of the output file, optionally a fully qualified path.
   * @param title       - Title for the Snippet
   * @param prefix       - Prefix for Snippet trigger
   * @param description - Description for the Snippet
   * @param create     - Appending TO a Snippets File or Creating a new File
   * @param force    - Force flag to write to potentially invalid JSON files
   * @param print    - Print to stdout
   * @returns A status code indicating success or failure.
   */
  export function parseFileWriteOutput(
    inputFilePath: string,
    outputFilePath: string,
    title: string,
    prefix: string,
    description: string,
    create: boolean,
    force: boolean,
    print: boolean
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
   *      "JS NAPI Usage:",
   *      "js_napiUsage",
   *      "using the napi interface from node"
   *      true,
   *      true,
   *      true
   * );
   *
   * @param text - The path to the folder.
   * @param outputFilePath - The name of the output file, optionally a fully qualified path.
   * @param title       - Title for the Snippet
   * @param prefix       - Prefix for Snippet trigger
   * @param description - Description for the Snippet
   * @param create     - Appending TO a Snippets File or Creating a new File
   * @param force    - Force flag to write to potentially invalid JSON files
   * @param print    - Print to stdout
   * @returns A status code indicating success or failure.
   */
  export function parseStringWriteToFile(
    text: string,
    outputFilePath: string,
    title: string,
    prefix: string,
    description: string,
    create: boolean,
    force: boolean,
    print: boolean
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
  export function convertDirToSnippet(
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
  export function parseFileGetSnippet(
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
  export function parseStringFromNode(text: string): string;

  export function writeFileCurrPath(filePath: string): number;
  export function writeFileToPathAbs(filePath: string): number;
}
