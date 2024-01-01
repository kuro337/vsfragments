const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const transformFileToFragment = @import("json_parser").transformFileToFragment;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

// ====================== CORE_NAPI_EXPORTS ======================

export fn parseFileGetSnippet(file_path: [*c]const u8, print_out: bool) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const zig_file_path = std.mem.span(file_path);

    const snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
}

// Pass Selected Lines Directly to Zig
export fn parseSnippetFromString(lines: [*c]const u8) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const snippet = Snippet.createFromSingleString(allocator, lines, false) catch |err| {
        std.debug.panic("Failed to Parse Text from Direct String {s}\nErr:{}", .{ lines, err });
    };

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
}

// Get Metadata from User - gets called by createSnippetWithMetadata from JS
export fn createSnippetWithMetadata(file_path: [*:0]const u8, title: [*:0]const u8, prefix: [*:0]const u8, description: [*:0]const u8, new_snippet_file: bool, print_out: bool) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const zig_file_path = std.mem.span(file_path);

    const zig_title = std.mem.span(title);
    const zig_prefix = std.mem.span(prefix);
    const zig_description = std.mem.span(description);

    var snippet = parseFileReturnSnippet(allocator, zig_file_path, false) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    // so it adds a surrounding { }

    if (new_snippet_file == true) snippet.create_flag = true;

    snippet.setMetadata(zig_title, zig_prefix, zig_description);

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    if (print_out == true) printFragmentBufferedFileIO(snippet) catch |err| {
        std.debug.panic("Could Not Print Snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
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
