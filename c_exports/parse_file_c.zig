const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const Ally = @import("ffi_ally").Ally;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const transformFileToFragment = @import("json_parser").transformFileToFragment;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

pub fn main() !void {
    // Test File Path :  /Users/kuro/Documents/Code/JS/FFI/zig_c_napi/ffi/index.js
    const file_path = "/Users/kuro/Documents/Code/JS/FFI/zig_c_napi/ffi/indexparsedcopy.js";
    const title = "Zig Metadata Export";
    const prefix = "zigmetadatatest";
    const description = "Custom Description for Metadata Export";

    const c_str = createSnippetWithMetadata(file_path, title, prefix, description, false);
    _ = c_str; // autofix

    //std.debug.print("Parsed Snippet with Metadata {s}", .{c_str});

    // final_buf[0 .. final_buf.len - 1 :0] In case c string type issues
}
// ====================== CORE_NAPI_EXPORTS ======================

export fn parseFileGetSnippet(file_path: [*c]const u8, print_out: bool) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const zig_file_path = std.mem.span(file_path);

    const snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    return snippet.toCStr(allocator);
}

// Pass Selected Lines Directly to Zig
export fn parseSnippetFromString(lines: [*c]const u8) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const snippet = Snippet.createFromSingleString(allocator, lines, false) catch |err| {
        std.debug.panic("Failed to Parse Text from Direct String {s}\nErr:{}", .{ lines, err });
    };

    return snippet.toCStr(allocator);
}

// Get Metadata from User - gets called by createSnippetWithMetadata from JS
export fn createSnippetWithMetadata(file_path: [*:0]const u8, title: [*:0]const u8, prefix: [*:0]const u8, description: [*:0]const u8, print_out: bool) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const zig_file_path = std.mem.span(file_path);

    const zig_title = std.mem.span(title);
    const zig_prefix = std.mem.span(prefix);
    const zig_description = std.mem.span(description);

    var snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    snippet.setMetadata(zig_title, zig_prefix, zig_description);

    const format_to_str = std.fmt.allocPrint(allocator, "{s}\n", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    //std.fmt.allocPrint(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype)
    std.debug.print("PrintAlloc Struct\n\n{s}\n\n", .{format_to_str});

    return snippet.toCStr(allocator);
}

// createSnippetWithMetadata(
//   filePath: string,
//   title: string,
//   prefix: string,
//   description: string,
//   print_out:bool,
// ): string;

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

// vsfragment set on Path
