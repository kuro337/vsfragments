const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const transformFileToFragment = @import("json_parser").transformFileToFragment;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

// Export this Function - it should accept a C string and return the Snippet String

pub fn main() !void {
    const file_name = "test.txt";

    const parsed_str = try parseFileGetSnippet(file_name);

    print("toString() Snippet \n\n{s}\n", .{parsed_str});
}

fn parseFileGetSnippet(file_path: [*c]const u8) ![*c]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();

    const allocator = arena.allocator();

    const zig_file_path = std.mem.span(file_path);

    // try parseFileAndPrint(allocator, file_path) (update it to return snippet instead of just printing)
    const snippet = try parseFileReturnSnippet(allocator, zig_file_path, true);
    const to_string = try snippet.toString(allocator);

    // Convert the slice to a C-style string if needed - dupeZ null terminates it.
    const c_string = allocator.dupeZ(u8, to_string) catch {
        return error.OutOfMemory;
    };
    return c_string.ptr;
}
// test to see how null input handled

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && \
//  ./vsfragment_fast -f test.txt

//  parseFileGetSnippet(filePath: string): string;

// zig build-exe vector.zig
// ./vector
// zig test file.zig

// C_Export Function
pub fn parseFileReturnSnippet(allocator: std.mem.Allocator, input_file_path: []const u8, print_stdout: bool) !Snippet {

    // 1. Read File -> Write Snippet to stdout

    const input_file_exists = try checkFileExists(input_file_path);

    if (input_file_exists == false) {
        handleInputFileNotExists(input_file_path);
        return error.FileNotFound;
    }

    // 2. Print Snippet

    const transformed_snippet = try transformFileToFragment(allocator, input_file_path, false);

    if (print_stdout == true) try printFragmentBufferedFileIO(transformed_snippet);

    return transformed_snippet;
}
