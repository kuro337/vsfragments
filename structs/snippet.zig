const std = @import("std");
const print = std.debug.print;

pub const Snippet = struct {
    title: []const u8,
    prefix: []const u8,
    body: [][]const u8,
    description: []const u8,
    create_flag: bool,
    force: bool,

    pub fn format(
        snippet: Snippet,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        if (snippet.create_flag == true) {
            try writer.print("{{\n", .{});
        }
        try writer.print("\t\"{s}\": {{\n\t\t\"prefix\": \"{s}\",\n\t\t\"body\": [\n", .{ snippet.title, snippet.prefix });
        for (snippet.body) |parsed_line| {
            try writer.print("\t\t\t{s}\n", .{parsed_line});
        }
        try writer.print("\t\t],\n\t\t\"description\": \"{s}\"\n\t}}\n", .{snippet.description});
        if (snippet.create_flag == true) {
            try writer.print("}}\n", .{});
        }
    }

    pub fn setMetadata(
        self: *Snippet,
        title: ?[]const u8,
        prefix: ?[]const u8,
        description: ?[]const u8,
        create_flag: ?bool,
        force: ?bool,
    ) void {
        if (title) |newTitle| {
            self.title = newTitle;
        }
        if (prefix) |newPrefix| {
            self.prefix = newPrefix;
        }
        if (description) |newDescription| {
            self.description = newDescription;
        }
        if (create_flag) |create| {
            self.create_flag = create;
        }
        if (force) |f| {
            self.force = f;
        }
    }

    pub fn destroy(self: *Snippet, allocator: std.mem.Allocator) void {
        for (self.body) |line| {
            allocator.free(line);
        }

        allocator.free(self.body);
    }

    // NOTE: use Snippet.convertFileToSnippet() everywhere - MOST efficient
    pub fn transformFileToSnippet(allocator: std.mem.Allocator, filename: []const u8) !Snippet {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var lines = std.ArrayList([]const u8).init(allocator);
        defer lines.deinit();

        var buf: [1024]u8 = undefined; //1024 bytes or 1kb

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            const line_copy = try allocator.dupe(u8, line);
            try lines.append(line_copy);
        }

        const file_lines = try lines.toOwnedSlice();
        defer {
            for (file_lines) |slice| {
                allocator.free(slice);
            }
            allocator.free(file_lines);
        }

        const snippet = try Snippet.createFromLines(allocator, file_lines, false);
        return snippet;
    }

    // append to existing snippets file
    // if file exists and they pass the -y flag we just insert into it by continuing below flow

    pub fn appendSnippet(self: *Snippet, allocator: std.mem.Allocator, output_file_path: []const u8, print_out: bool) !void {
        const file = try std.fs.openFileAbsolute(output_file_path, .{ .mode = .read_write });

        defer file.close();

        var snippet_insertion_pos: usize = 0;

        // Determine the file size
        const fileSize = try file.getEndPos();

        // Get Insertion Pos if File not Empty
        if (fileSize > 0) {

            // Allocate a buffer to hold the file content
            const buffer = try allocator.alloc(u8, fileSize);

            defer allocator.free(buffer);

            // Read the file content into the buffer
            _ = try file.readAll(buffer);
            const snippet_file_valid = try std.json.validate(allocator, buffer);

            if (snippet_file_valid == false and self.force == false) {
                std.debug.print("Malformed JSON Detected in Existing Snippet File. Use the --force flag to append to a potentially malformed Snippets file.\n", .{});
                return;
            }

            snippet_insertion_pos = findSecondLastBracePosition(buffer);
        }

        if (snippet_insertion_pos == 0) {
            _ = try file.write("{\n");
        } else {
            try file.seekTo(snippet_insertion_pos + 1);
            _ = try file.write(",\n");
        }

        const old_create_flag = self.create_flag;
        self.create_flag = false;

        // Write the snippet to the file
        const formatOptions = std.fmt.FormatOptions{};

        // Write the snippet to the file
        self.format("", formatOptions, file.writer()) catch unreachable;

        _ = try file.write("}");
        self.create_flag = old_create_flag;

        if (print_out) print("\nSuccessfully Updated Snippets File \x1b[92m{s}\x1b[0m\n", .{output_file_path});
    }

    // only writes if -y flag passed
    pub fn writeSnippet(self: *Snippet, output_file_path: []const u8, print_out: bool) !void {
        if (self.create_flag == false) {
            print("{s}", .{output_file_not_exists});
            print("\n{s}\n", .{msg_outputfile_missing});
            return;
        }

        const file = std.fs.createFileAbsolute(output_file_path, .{}) catch |err| {
            std.debug.panic("Failed to Create new Snippets File:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
        };

        defer file.close();

        const formatOptions = std.fmt.FormatOptions{};

        // Write the snippet to the file
        try self.format("", formatOptions, file.writer());

        if (print_out) print("\x1b[92mSuccessfully Created Snippets File \x1b[0m\x1b[97m{s}\x1b[0m\n", .{output_file_path});
    }

    // read file and pass lines directly to parseLine
    pub fn convertFileToSnippet(allocator: std.mem.Allocator, filename: []const u8, create_flag: bool) !Snippet {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var parsed_lines = std.ArrayList([]const u8).init(allocator);
        defer parsed_lines.deinit();

        var buf: [1024]u8 = undefined; //1024 bytes or 1kb

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            const serialized_line = try parseLine(allocator, line);

            try parsed_lines.append(serialized_line);
        }

        const last_line = parsed_lines.pop();

        const new_slice = try allocator.alloc(u8, last_line.len - 1);

        @memcpy(new_slice, last_line[0 .. last_line.len - 1]);

        defer allocator.free(last_line);

        try parsed_lines.append(new_slice);

        return Snippet{
            .title = "VSCode Code Snippet",
            .prefix = "prefix_insertSnippet",
            .body = try parsed_lines.toOwnedSlice(),
            .description = "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.",
            .create_flag = create_flag,
            .force = false,
        };
    }

    pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]const u8 {
        var escapedLineBuilder = std.ArrayList(u8).init(allocator);
        defer escapedLineBuilder.deinit();

        // Add opening quote
        try escapedLineBuilder.append('\"');

        var prev_backslash_index: usize = 0;

        var spaceCount: usize = 0;
        for (line, 0..) |char, i| {
            switch (char) {
                ' ' => {
                    spaceCount += 1;
                    if (spaceCount == 4) {
                        // Handle tab logic
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('t');
                        spaceCount = 0;
                    } else {
                        // Append a single space
                        try escapedLineBuilder.append(' ');
                    }
                },
                '\\' => {
                    // Append a backslash to escape it, without adding any spaces
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append('\\');
                    if (i == prev_backslash_index + 1) {
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('\\');
                    }
                    prev_backslash_index = i;
                },
                '"' => {
                    // Escape special characters
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append(char);
                },
                '$' => { // prev above block has '$','"' together - this one is new for $
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append(char);
                },
                else => {
                    // Reset space counter and append other characters directly
                    spaceCount = 0;
                    try escapedLineBuilder.append(char);
                },
            }
        }

        // Add closing quote
        try escapedLineBuilder.append('\"');

        // Add comma except for the last line
        try escapedLineBuilder.append(',');

        return escapedLineBuilder.toOwnedSlice();
    }

    // IMPORTANT -> call snippet.destroy() once done to free String Memory

    pub fn createFromLines(allocator: std.mem.Allocator, lines: []const []const u8, write_flag: bool) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator);
        defer parsedLines.deinit();

        const totalLines = lines.len;

        // for last line dont add a Comma
        for (lines, 0..) |line, i| {
            const serialized_line = try parseLine(allocator, line);

            // If it's the last line, remove the last character (the comma)

            if (i == totalLines - 1) {
                const new_slice = try allocator.alloc(u8, serialized_line.len - 1);

                @memcpy(new_slice, serialized_line[0 .. serialized_line.len - 1]);
                allocator.free(serialized_line);

                try parsedLines.append(new_slice);

                //try parsedLines.append(serialized_line[0 .. serialized_line.len - 1]);
                break;
            }

            try parsedLines.append(serialized_line);
        }

        return Snippet{
            .title = "Go HTTP2 Server Snippet",
            .prefix = "gohttpserver",
            .body = try parsedLines.toOwnedSlice(),
            .description = "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.",
            .create_flag = write_flag,
            .force = false,
        };
    }

    pub fn createFromSingleString(allocator: std.mem.Allocator, input: [*c]const u8, write_flag: bool) !Snippet {

        // Convert Input to a Zig String
        const cStringSlice: []const u8 = std.mem.span(input);

        const split_lines = try convertStringToStringSlice(allocator, cStringSlice);
        defer allocator.free(split_lines);

        if (write_flag == true) {
            const out = std.io.getStdOut();
            var buf = std.io.bufferedWriter(out.writer());
            //var w = buf.writer();
            try buf.writer().print("Direct String Received in Snippet from JS-C: \n{s}\n", .{cStringSlice});
            try buf.flush();
        }

        const snippet = try Snippet.createFromLines(allocator, split_lines, write_flag);

        return snippet;
    }
};

// =================== EXTENSIONS =====================
// EXTENSIONS - Converting Multiple Files

// test "Large Snippet File from All Files in Dir" {}

fn concatStrings(allocator: std.mem.Allocator, one: []const u8, two: []const u8) ![]u8 {
    if (one[one.len - 1] != '/') {
        const new_len = one.len + two.len + 1;
        const concat = try allocator.alloc(u8, new_len);

        return std.fmt.bufPrint(concat, "{s}/{s}", .{ one, two });
    } else {
        const new_len = one.len + two.len;

        const concat = try allocator.alloc(u8, new_len);

        return try std.fmt.bufPrint(concat, "{s}{s}", .{ one, two });
    }
}

fn checkIfPathExists(path: []const u8) !bool {
    _ = std.fs.cwd().statFile(path) catch |err| {
        std.debug.print("No File Found at Path:{}\n", .{err});

        if (err == error.FileNotFound) return false;
        return err;
    };

    std.debug.print("Output directory exists:{s}\n", .{path});

    return true;
}

fn isBinaryFile(fileName: []const u8) bool {
    // Add more extensions if needed
    // need to handle empty extensions for binaries
    const binaryExtensions = &[_][]const u8{ ".o", ".bin", ".exe", ".dll" };
    for (binaryExtensions) |ext| {
        if (std.mem.endsWith(u8, fileName, ext)) {
            return true;
        }
    }
    return false;
}

// IMPORTANT - MAKE SURE WE CHECK FILE NOT BINARY AND VALID UTF8
// use std.unicode utilities to check

test "Reading all Files from a Directory and Converting to a Single Snippet File" {
    const allocator = std.testing.allocator;

    const input_file_dir = "/Users/kuro/Documents/Code/Zig/FileIO/file";
    const output_dir_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/backup";

    if (!try checkIfPathExists(output_dir_path)) {
        _ = try std.fs.cwd().makeDir(output_dir_path);
    }

    var dir = try std.fs.cwd().openDir(input_file_dir, .{ .iterate = true });
    defer dir.close();

    const combined_file_path = try concatStrings(allocator, output_dir_path, "backup.json");
    defer allocator.free(combined_file_path);

    var it = dir.iterate();

    var i: usize = 0;
    while (try it.next()) |entry| {
        if (entry.kind == std.fs.File.Kind.file) {
            if (isBinaryFile(entry.name)) {
                std.debug.print("Non UTF-8 File: {s}\n", .{entry.name});
                continue;
            }

            const input_file_full_path = try concatStrings(allocator, input_file_dir, entry.name);
            defer allocator.free(input_file_full_path);
            // std.debug.print("File: {s}\n", .{input_file_full_path});

            var snippet = try Snippet.convertFileToSnippet(allocator, input_file_full_path, true);

            defer snippet.destroy(allocator);

            if (i == 0) {
                try snippet.writeSnippet(combined_file_path, false);
            } else {
                try snippet.appendSnippet(allocator, combined_file_path, false);
            }

            i += 1;
        } else {
            // std.debug.print("Not a File: {s}-{}\n", .{ entry.name, entry.kind });
        }
    }

    try std.fs.cwd().deleteFile(combined_file_path);

    try std.testing.expect(true);
}

fn listFilesInDir(dirPath: []const u8) !void {
    var dir = try std.fs.cwd().openDir(dirPath, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        std.debug.print("File: {s}-{}\n", .{ entry.name, entry.kind });
    }
}

pub const output_file_not_exists = "\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mOutput Path Snippets File does not exist.\x1b[0m\n";
pub const msg_outputfile_missing = "\x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\n\x1b[97m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";

// =================== HELPERS =====================
// HELPERS - Find second last Brace Position

fn findSecondLastBracePosition(buffer: []const u8) usize {
    var braceCount: usize = 0;
    var isInComment = false;

    var index = buffer.len - 1;
    while (index > 0) {
        const char = buffer[index];

        // Skip the current line if it's a comment.
        if (isInComment) {
            if (char == '\n') {
                isInComment = false;
            }
            index -= 1;
            continue;
        }

        // Check for start of a single line comment.
        if (index > 0 and buffer[index - 1] == '/' and char == '/') {
            isInComment = true;
            index -= 2; // Skip the "//"
            continue;
        }

        // Count closing braces.
        if (char == '}') {
            braceCount += 1;
            if (braceCount == 2) {
                return index;
            }
        }

        index -= 1;
    }

    // Return 0 if less than two closing braces found.
    return 0;
}

// =================== SNIPPET TESTS =====================

test "Snippet File Convert" {
    const allocator = std.testing.allocator;
    //  Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/testfile.txt

    const file_name = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/testfile.txt";

    const snippet = try Snippet.convertFileToSnippet(allocator, file_name, true);
    const format_to_str = try std.fmt.allocPrint(allocator, "{s}", .{snippet});

    defer {
        for (snippet.body) |line| {
            allocator.free(line);
        }
        allocator.free(snippet.body);
        allocator.free(format_to_str);
    }

    // std.debug.print("Direct Convert\n{s}\n", .{format_to_str});
}

test "Snippet Direct Write File Convert" {
    const allocator = std.testing.allocator;
    //  Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/testfile.txt

    const file_name = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/testfile.txt";
    const new_file_name = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/snippetcreate.code-snippets";

    var snippet = try Snippet.convertFileToSnippet(allocator, file_name, true);

    try snippet.writeSnippet(new_file_name, false);

    defer {
        for (snippet.body) |line| {
            allocator.free(line);
        }
        allocator.free(snippet.body);
    }
}

test "Snippet Append Fragment to File" {
    const allocator = std.testing.allocator;
    //  Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/testfile.txt

    const file_name = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/testfile.txt";
    const existing_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/snippetcreate.code-snippets";

    var snippet = try Snippet.convertFileToSnippet(allocator, file_name, false);

    try snippet.appendSnippet(allocator, existing_file, false);

    defer {
        for (snippet.body) |line| {
            allocator.free(line);
        }
        allocator.free(snippet.body);
    }

    try std.fs.cwd().deleteFile(existing_file);
}

// test "Test Snippet Parse From Direct C String" {
//     const mock_selection =
//         \\hello
//         \\world
//         \\\\\\\\
//         \\\n\n\n\n\n
//         \\nextline nextline
//         \\oneline \n\n    aaaa\\\\ \ttttt XXXX
//         \\oneline \n\n    aaaa\\\\ \ttttt XXXX
//         \\          \!!!!!,,,,,
//         \\
//         \\
//     ;

//     const allocator = std.testing.allocator;

//     const cString: [*c]const u8 = "Your test string here";
//     const cStringSlice: []const u8 = std.mem.span(cString);

//     const split_s = try convertStringToStringSlice(allocator, cStringSlice);
//     defer allocator.free(split_s);

//     acceptStringSlicesConst(split_s);

//     try Snippet.createFromSingleString(allocator, mock_selection, true);
//     try Snippet.createFromSingleString(allocator, cString, true);
// }

// ============== STRING CONVERSION UTILS ==============

pub fn convertStringToStringSlice(allocator: std.mem.Allocator, code_str: []const u8) ![][]const u8 {
    var splitLines = std.ArrayList([]const u8).init(allocator);
    defer splitLines.deinit();

    var split = std.mem.splitScalar(u8, code_str, '\n');

    while (split.next()) |line| {
        try splitLines.append(line);
    }

    return splitLines.toOwnedSlice();
}

pub fn acceptStringSlicesConst(str_slices: []const []const u8) void {
    const len = str_slices.len;
    std.debug.print("Length of Passed String Slices {d}\n", .{len});

    for (str_slices) |st| {
        std.debug.print("{s}\n", .{st});
    }
}
// ============================================

pub fn testSnippetToString(allocator: std.mem.Allocator, snippet: Snippet) !void {
    const to_string = try snippet.toString(allocator);

    print("toString() Snippet \n\n{s}\n", .{to_string});

    const SnippetContent = struct {
        prefix: []u8,
        body: [][]u8,
        description: []u8,
    };

    // DEFINE JSON STRING , PARSE INTO JSON VALUE (noprint) - THEN STRINGIFY JSON VALUE
    const json =
        \\{"prefix": "gohttpserver","body": ["hello"],"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."}
    ;

    const parsed = std.json.parseFromSlice(
        SnippetContent,
        allocator,
        json,
        .{},
    ) catch |err| {
        std.debug.print("Error for Parse: {}\n", .{err});
        return;
    };

    defer parsed.deinit();

    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());

    try std.json.stringify(parsed.value, .{}, string.writer());

    print("Stringified {s}\n", .{string.items});

    //const parsed_snip = parsed.value;

    //print("Parsed Struct {}\n", .{parsed_snip});
    print("Parsed No Err\n", .{});

    // ===================================================
    // ===================================================

    const ParseObject = struct {
        thisisunknown: SnippetContent,
    };

    const json_nested =
        \\{
        \\"thisisunknown": 
        \\  {
        \\      "prefix": "anystring",
        \\      "body": ["array","values"],
        \\      "description": "any string here"
        \\  }
        \\}
    ;

    const nested_parse = std.json.parseFromSlice(
        ParseObject,
        allocator,
        json_nested,
        .{},
    ) catch |err| {
        std.debug.print("Error for Nested Parse: {}\n", .{err});
        return;
    };

    defer nested_parse.deinit();

    var n_buf: [4096]u8 = undefined;
    var fba_n = std.heap.FixedBufferAllocator.init(&n_buf);
    var string_n = std.ArrayList(u8).init(fba_n.allocator());

    try std.json.stringify(nested_parse.value, .{}, string_n.writer());

    print("Stringified {s}\n", .{string_n.items});

    print("Parsed nested No Err\n", .{});
}
