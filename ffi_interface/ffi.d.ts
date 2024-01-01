/* Interface for Module Exposed from napi */

interface Addon {
  /* Core Library Methods */

  getPath(filePath: string): string;
  writeFileCurrPath(filePath: string): number;
  writeFileToPathAbs(filePath: string): number;
  parseFileGetSnippet(filePath: string, print: boolean): string;
  parseStringFromJS(filePath: string): string;

  createSnippetWithMetadata(
    filePath: string,
    title: string,
    prefix: string,
    description: string,
    newFile: boolean,
    printOut: boolean
  ): string;

  parseFileWriteSnippetToPath(
    filePath: string,
    title: string,
    prefix: string,
    description: string,
    newFile: boolean,
    printOut: boolean
  ): number;

  parseRawGetSnippet(rawStr: string): string;
  parseRawWriteSnippetToPath(rawStr: string): number;

  /* Integration Utils  */
  zigAdd(a: number, b: number): number;
  getString(): string;
  testWriteSampleFile(): number;
}

interface Snippet {
  title: string;
  prefix: string;
  body: string[];
  description: string;
  create_flag: boolean;
}

interface Metadata {
  inputPath: string;
  title: string;
  prefix: string;
  description: string;
  false: string;
  newFile: string;
}

/* 

FFI Struct for Fragment

pub const Snippet = struct {
    title: []const u8,
    prefix: []const u8,
    body: [][]const u8,
    description: []const u8,
    create_flag: bool,
  }

*/

interface AddonTest {}

declare const addon: Addon;

export = addon;
