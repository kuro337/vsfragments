const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const convertDirectoryToSnippetFile = @import("snippet").convertDirectoryToSnippetFile;

const checkFileExists = @import("modify_snippet").checkFileExists;
const handleFileNotExists = @import("create_file").handleFileNotExists;
const writeBufferedIO = @import("write_results").writeBufferedIO;

// *** napi_c : Pass a File Path and return the Snippet as a string

// -> addon.parseFileGetSnippet(path : string, new_file : bool, print_out : bool) (Node)

export fn parseFileGetSnippet(file_path: [*c]const u8, new_snippet_file: bool, print_out: bool) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const zig_file_path = std.mem.span(file_path);

    var snippet = parseFileReturnSnippet(allocator, zig_file_path, print_out) catch |err| {
        std.debug.panic("Failed to Parse Text from File {s}\nErr:{}", .{ zig_file_path, err });
    };

    snippet.create_flag = new_snippet_file;

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
}

// *** napi_c : Pass a String directLy and return the Snippet

// -> addon.parseStringFromJS(inputString) (Node)

export fn parseSnippetFromString(lines: [*c]const u8) [*:0]const u8 {
    const allocator = std.heap.c_allocator;

    const snippet = Snippet.createFromString(allocator, std.mem.span(lines), false) catch |err| {
        std.debug.panic("Failed to Parse Text from Direct String {s}\nErr:{}", .{ lines, err });
    };

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
}

// *** napi_c : Create a Snippet with Metadata

// -> addon.createSnippetWithMetadata(filePath,title,prefix,description,new_file:bool,print_out:bool) (Node)

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

    snippet.setMetadata(zig_title, zig_prefix, zig_description, new_snippet_file, false);

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
    };

    if (print_out == true) writeBufferedIO(snippet) catch |err| {
        std.debug.panic("Could Not Print Snippet: {}\n", .{err});
    };

    return format_to_str.ptr;
}

// *** napi_c : Convert a Directory to a Single Snippet

// -> convertDirToSnippet(dir_path:string , output_filename:string) (Node)

export fn convertDirToSnippet(dir_path: [*:0]const u8, output_file: [*:0]const u8) c_int {
    const allocator = std.heap.c_allocator;

    const num_files_converted = convertDirectoryToSnippetFile(allocator, std.mem.span(dir_path), std.mem.span(output_file)) catch |err| {
        std.debug.panic("Failed Snippet.convertFileToSnippet({s},{s}):\nError:\x1b[31m{}\x1b[0m\n\n", .{ dir_path, output_file, err });
    };

    return @intCast(num_files_converted);
}

// *** napi_c : Read a File and Write to a Snippet File

// -> parseFileWriteOutput(input_f, output_f, title,prefix,desc,create,force,print_out) : int (0/1) (Node)

export fn parseFileWriteOutput(
    input_file: [*:0]const u8,
    output_file: [*:0]const u8,
    title: [*:0]const u8,
    prefix: [*:0]const u8,
    description: [*:0]const u8,
    create: bool,
    force: bool,
    print_out: bool,
) c_int {
    const allocator = std.heap.c_allocator;

    const zig_input_file = std.mem.span(input_file);
    const zig_output_file = std.mem.span(output_file);
    const zig_title = std.mem.span(title);
    const zig_prefix = std.mem.span(prefix);
    const zig_description = std.mem.span(description);

    var status_code: c_int = 0;

    const input_exists = checkFileExists(zig_input_file) catch |err| {
        std.debug.print("Error Happened Checking for File {s}\n{}", .{ zig_input_file, err });
        return status_code;
    };

    if (!input_exists) {
        handleFileNotExists(zig_input_file);
        status_code = 1;
        return status_code;
    }

    const output_exists = checkFileExists(zig_output_file) catch |err| {
        std.debug.print("Error Happened Checking for File {s}\n{}", .{ zig_output_file, err });
        return status_code;
    };

    if (!output_exists and !create) {
        handleFileNotExists(zig_output_file);
        status_code = 1;
        return status_code;
    }

    var snippet = Snippet.convertFileToSnippet(allocator, zig_input_file, create) catch |err| {
        std.debug.print("Error During Snippet Write for Input:{s} Output:{s}\n{}", .{ zig_input_file, zig_output_file, err });
        status_code = 1;
        return status_code;
    };

    defer snippet.destroy(allocator);

    snippet.setMetadata(zig_title, zig_prefix, zig_description, create, force);
    snippet.setSnippetTime(allocator);

    if (print_out) writeBufferedIO(snippet) catch |err| {
        std.debug.print("Could not Write to stdout\n{}\n", .{err});
        // - buffered stdout write w/ snippet
    };

    switch (output_exists) {
        true => {
            snippet.appendSnippet(allocator, zig_output_file, print_out) catch |err| {
                std.debug.print("Error During Snippet Append for Input:{s} Output:{s}\n{}", .{ zig_input_file, zig_output_file, err });
                status_code = 1;
                return status_code;
            };
        },
        false => {
            snippet.writeSnippet(zig_output_file, print_out) catch |err| {
                std.debug.print("Failed Write Snippet\n:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
                status_code = 1;
                return status_code;
            };
        },
    }

    return status_code;
}

// *** napi_c : Pass a String directLy and Write to a File

// -> addon.parseFileWriteOutput (str, output_f, title,prefix,desc,create,force,print_out) : c_str (Node)

export fn parseStringWriteToFile(
    lines: [*c]const u8,
    output_file: [*:0]const u8,
    title: [*:0]const u8,
    prefix: [*:0]const u8,
    description: [*:0]const u8,
    create: bool,
    force: bool,
    print_out: bool,
) [*:0]const u8 {
    const zig_output_file = std.mem.span(output_file);
    const zig_title = std.mem.span(title);
    const zig_prefix = std.mem.span(prefix);
    const zig_description = std.mem.span(description);

    const allocator = std.heap.c_allocator;

    var snippet = Snippet.createFromString(allocator, std.mem.span(lines), false) catch |err| {
        std.debug.panic("Failed to Parse Text from Direct String {s}\nErr:{}", .{ lines, err });
    };

    defer snippet.destroy(allocator);

    snippet.setMetadata(zig_title, zig_prefix, zig_description, create, force);
    snippet.setSnippetTime(allocator);

    const format_to_str = std.fmt.allocPrintZ(allocator, "{s}", .{snippet}) catch |err| {
        std.debug.panic("Error formatting snippet: {}\n", .{err});
        false;
    };

    // const output_exists = checkFileExists(zig_output_file)

    const output_exists = checkFileExists(zig_output_file) catch |err| blk: {
        std.debug.print("Error Happened Checking for File {s}\n{}", .{ zig_output_file, err });
        break :blk false;
    };

    if (!output_exists and !create) {
        handleFileNotExists(zig_output_file);
        return format_to_str.ptr;
    }

    switch (output_exists) {
        true => {
            snippet.appendSnippet(allocator, zig_output_file, print_out) catch |err| {
                std.debug.print("Error During Snippet Append for Output:{s}\n{}", .{ zig_output_file, err });

                //         return format_to_str.ptr;
            };
        },
        false => {
            snippet.writeSnippet(zig_output_file, print_out) catch |err| {
                std.debug.print("Failed Write Snippet\n:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
                //           return format_to_str.ptr;
            };
        },
    }
    return format_to_str.ptr;
}

// ============================================

pub fn parseFileReturnSnippet(allocator: std.mem.Allocator, input_file_path: []const u8, print_stdout: bool) !Snippet {

    // 1. Read File -> Write Snippet to stdout

    const input_file_exists = try checkFileExists(input_file_path);

    if (input_file_exists == false) {
        handleFileNotExists(input_file_path);
        return error.FileNotFound;
    }

    // 2. Print Snippet

    const transformed_snippet = try Snippet.convertFileToSnippet(allocator, input_file_path, false);

    if (print_stdout == true) try writeBufferedIO(transformed_snippet);

    return transformed_snippet;
}

test "Snippet Convert Input File and Write Output File C Test" {
    const allocator = std.testing.allocator;
    _ = allocator; // autofix

    const input_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/control_char_data/contains_controlchars.txt";

    const output_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup/output/cnapi_writesnippet.json";

    const result = parseFileWriteOutput(
        input_file,
        output_file,
        "C_NAPI_run",
        "cnapi_testsnip",
        "napi run test desc",
        true,
        true,
        true,
    );

    std.debug.print("Result of call: {d}\n", .{result});

    try std.testing.expectEqual(0, result);
}

test "Snippet Dir Convert C Test" {
    const allocator = std.testing.allocator;
    _ = allocator; // autofix

    const dir_path = "../tests/mock/backup/input";
    const output_file = "../tests/mock/backup/output/testing.code-snippets";

    const successul_files = convertDirToSnippet(dir_path, output_file);

    try std.testing.expectEqual(5, successul_files);

    //   try std.fs.cwd().deleteFile(output_file);
}

// Passing String directly to Snippet Struct

export fn processStringFromCJS(input: [*c]const u8) void {
    const inputString = std.mem.span(input);
    std.debug.print("String received in Zig from JS-C: {s}\n", .{inputString});
}

// /Users/kuro/Library/Application Support/Code/User/snippets/newsnips

// /Users/kuro/Library/Application Support/Code/User/snippets/c.json
