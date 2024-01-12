const std = @import("std");
const convertDirectoryToSnippetFile = @import("snippet").convertDirectoryToSnippetFile;

// test "Batch Write Tests" {
//     const allocator = std.testing.allocator;
//     _ = allocator; // autofix

//     const dir_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/input";

//     const output_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/output/testing.code-snippets";

//     const successul_files = try convertDirectoryToSnippetFile(dir_path, output_file);

//     try std.testing.expectEqual(5, successul_files);

//     try std.fs.cwd().deleteFile(output_file);
// }
