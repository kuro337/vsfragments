const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const Ally = @import("ffi_ally").Ally;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const transformFileToFragment = @import("json_parser").transformFileToFragment;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

// ====================== CORE_NAPI_EXPORTS ======================

export fn parseFileGetSnippet(file_path: [*c]const u8, print_out: bool) [*:0]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const zig_file_path = std.mem.span(file_path);

    const snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    return snippet.toCStr(std.heap.c_allocator);
}

// Pass Selected Lines Directly to Zig
export fn parseSnippetFromString(lines: [*c]const u8) [*:0]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const snippet = Snippet.createFromSingleString(allocator, lines, false) catch |err| {
        std.debug.panic("Failed to Parse Text from Direct String {s}\nErr:{}", .{ lines, err });
    };

    return snippet.toCStr(std.heap.c_allocator);
}

// ============================================

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

// Passing String directly to Snippet Struct

export fn processStringFromCJS(input: [*c]const u8) void {
    const inputString = std.mem.span(input);
    std.debug.print("String received in Zig from JS-C: {s}\n", .{inputString});
}
