const std = @import("std");
const print = std.debug.print;
const parseFileGetSnippet = @import("parse_file_c").parseFileGetSnippet;

pub fn main() void {
    const file_name = "test.txt";

    const parsed_str = parseFileGetSnippet(file_name);

    print("toString() Snippet \n\n{s}\n", .{parsed_str});
}

// export fn parseFileGetSnippet(file_path: [*c]const u8) [*c]const u8 {
//     var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//     //defer arena.deinit();

//     const allocator = arena.allocator();

//     const zig_file_path = std.mem.span(file_path);

//     // try parseFileAndPrint(allocator, file_path) (update it to return snippet instead of just printing)

//     const snippet = parseFileReturnSnippet(allocator, zig_file_path, true) catch |err| {
//         std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
//     };

//     // const snippet = try parseFileReturnSnippet(allocator, zig_file_path, true);
//     // const to_string = try snippet.toString(allocator);

//     const to_string = snippet.toString(allocator) catch |err| {
//         std.debug.panic("Failed to Convert to String for File {s}\nErr:{}", .{ zig_file_path, err });
//     };

//     // Convert the slice to a C-style string if needed - dupeZ null terminates it.
//     const c_string = allocator.dupeZ(u8, to_string) catch |err| {
//         std.debug.panic("Failed to Convert to C String for File {s}\nErr:{}", .{ zig_file_path, err });
//     };
//     return c_string.ptr;
// }

// test to see how null input handled

//  cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
// ./vsfragment_fast -f test.txt

//  parseFileGetSnippet(filePath: string): string;

// zig build-exe vector.zig
// ./vector
// zig test file.zig

// C_Export Function
// pub fn parseFileReturnSnippet(allocator: std.mem.Allocator, input_file_path: []const u8, print_stdout: bool) !Snippet {

//     // 1. Read File -> Write Snippet to stdout

//     const input_file_exists = try checkFileExists(input_file_path);

//     if (input_file_exists == false) {
//         handleInputFileNotExists(input_file_path);
//         return error.FileNotFound;
//     }

//     // 2. Print Snippet

//     const transformed_snippet = try transformFileToFragment(allocator, input_file_path, false);

//     if (print_stdout == true) try printFragmentBufferedFileIO(transformed_snippet);

//     return transformed_snippet;
// }
