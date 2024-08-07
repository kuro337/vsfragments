const std = @import("std");
const print = std.debug.print;
const timestamp = @import("timestamp");

const vsfragment = @This();

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

    // Flushes current Snippet to stdout
    pub fn flushStdout(self: *Snippet) !void {
        const out = std.io.getStdOut();
        var buf = std.io.bufferedWriter(out.writer());
        var w = buf.writer();
        try w.print("{s}\n", .{self});
        try buf.flush();
        return;
    }

    pub fn setMetadata(
        self: *Snippet,
        title: []const u8,
        prefix: []const u8,
        description: []const u8,
        create_flag: bool,
        force: bool,
        time: bool,
    ) void {
        if (time and title.len > 1) {
            const allocator = std.heap.c_allocator;
            const time_str = timestamp.getTimestampString(allocator) catch |err| blk: {
                std.debug.print("Failed to get timestamp:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
                break :blk title;
            };

            self.title = std.fmt.allocPrintZ(allocator, "{s} {s}", .{ title, time_str }) catch |err| blk: {
                std.debug.print("Error Creating Title with Time\nErr:{}\n", .{err});
                allocator.free(time_str);
                break :blk title;
            };
        } else if (title.len > 1) {
            self.title = title;
        } else if (time) {
            self.setSnippetTime(std.heap.c_allocator);
        }

        if (prefix.len > 1) {
            self.prefix = prefix;
        }
        if (description.len > 1) {
            self.description = description;
        }
        if (create_flag) {
            self.create_flag = create_flag;
        }
        if (force) {
            self.force = force;
        }
    }

    pub fn setSnippetTime(self: *Snippet, allocator: std.mem.Allocator) void {
        const yyyy_mm_dd_hh_mm_ss = timestamp.getTimestampString(allocator) catch |err| {
            std.debug.print("Failed to get timestamp:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
            return;
        };

        const new_len = self.title.len + yyyy_mm_dd_hh_mm_ss.len + 1;

        const concat = allocator.alloc(u8, new_len) catch |err| {
            std.debug.print("Failed to get timestamp:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
            return;
        };

        const title_with_timestamp = std.fmt.bufPrint(concat, "{s} {s}", .{ self.title, yyyy_mm_dd_hh_mm_ss }) catch |err| {
            std.debug.print("Failed to add timestamp to Title {s}\n{}\n", .{ self.title, err });

            allocator.free(concat);
            allocator.free(yyyy_mm_dd_hh_mm_ss);
            return;
        };

        std.debug.print("{s}\n", .{title_with_timestamp});

        self.title = title_with_timestamp;
    }

    pub fn destroy(self: *Snippet, allocator: std.mem.Allocator) void {
        for (self.body) |line| {
            allocator.free(line);
        }

        allocator.free(self.body);
    }

    // append to existing snippets file
    // if file exists and they pass the -y flag we just insert into it by continuing below flow

    pub fn appendSnippet(self: *Snippet, allocator: std.mem.Allocator, output_file_path: []const u8, print_out: bool) !void {
        const file = try std.fs.cwd().openFile(output_file_path, .{ .mode = .read_write });

        defer file.close();

        var snippet_insertion_pos: usize = 0;

        // Determine the file size
        const fileSize = try file.getEndPos();

        if (fileSize > 0) {
            const buffer = try allocator.alloc(u8, fileSize);

            defer allocator.free(buffer);

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

        const file = std.fs.cwd().createFile(output_file_path, .{ .read = true }) catch |err| {
            std.debug.panic("Failed to Create new Snippets File:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
        };

        defer file.close();

        // Write the snippet to the file

        const formatOptions = std.fmt.FormatOptions{};
        try self.format("", formatOptions, file.writer());

        if (print_out) print("\x1b[92mSuccessfully Created Snippets File \x1b[0m\x1b[97m{s}\x1b[0m\n", .{output_file_path});
    }

    // read file and pass lines directly to parseLine
    pub fn convertFileToSnippet(allocator: std.mem.Allocator, filename: []const u8, create_flag: bool) !Snippet {
        const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_write });
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
                    // to skip handling escaped characters - replace the if{}else{}spacecount=0 check
                    if (isControlCharacter(char)) {
                        const escapedChar = getEscapedControlChar(char);
                        for (escapedChar) |ec| {
                            try escapedLineBuilder.append(ec);
                        }
                    } else {
                        try escapedLineBuilder.append(char);
                    }
                    spaceCount = 0;
                },
            }
        }

        try escapedLineBuilder.append('\"');

        try escapedLineBuilder.append(',');

        return escapedLineBuilder.toOwnedSlice();
    }

    pub fn createFromLines(allocator: std.mem.Allocator, lines: []const []const u8, write_flag: bool) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator);
        defer parsedLines.deinit();

        const totalLines = lines.len;

        for (lines, 0..) |line, i| {
            const serialized_line = try parseLine(allocator, line);

            if (i == totalLines - 1) { // If it's the last line, remove the last character (the comma)
                const new_slice = try allocator.alloc(u8, serialized_line.len - 1);

                @memcpy(new_slice, serialized_line[0 .. serialized_line.len - 1]);
                allocator.free(serialized_line);

                try parsedLines.append(new_slice);

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

    pub fn createFromString(allocator: std.mem.Allocator, code_str: []const u8, write_flag: bool) !Snippet {
        var parsed_lines = std.ArrayList([]const u8).init(allocator);
        defer parsed_lines.deinit();

        var split = std.mem.splitScalar(u8, code_str, '\n');

        while (split.next()) |line| {
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
            .create_flag = write_flag,
            .force = false,
        };
    }

    pub fn appendSnippetFilePassed(
        self: *Snippet,
        file: std.fs.File,
        print_out: bool,
    ) !void {
        const formatOptions = std.fmt.FormatOptions{};
        self.format("", formatOptions, file.writer()) catch unreachable;

        if (print_out) print("\nSuccessfully Appended to Passed File\n", .{});
    }
};

// ***** extensions

fn isControlCharacter(char: u8) bool {
    return char < 0x20 or char == 0x7F; // ascii control characters are in the range 0x00-0x1F and 0x7F.
}

fn getEscapedControlChar(char: u8) []const u8 {
    return switch (char) {
        0 => "\\0", // Null
        1 => "^A", // Start of Heading
        2 => "^B", // Start of Text
        3 => "^C", // End of Text
        4 => "^D", // End of Transmission
        5 => "^E", // Enquiry
        6 => "^F", // Acknowledge
        7 => "\\a", // Bell
        8 => "\\b", // Backspace
        9 => "\\t", // Horizontal Tab
        10 => "\\n", // Line Feed
        11 => "\\v", // Vertical Tab
        12 => "\\f", // Form Feed
        13 => "\\r", // Carriage Return
        14 => "^N", // Shift Out
        15 => "^O", // Shift In
        16 => "^P", // Data Link Escape
        17 => "^Q", // Device Control 1
        18 => "^R", // Device Control 2
        19 => "^S", // Device Control 3
        20 => "^T", // Device Control 4
        21 => "^U", // Negative Acknowledge
        22 => "^V", // Synchronous Idle
        23 => "^W", // End of Transmission Block
        24 => "^X", // Cancel
        25 => "^Y", // End of Medium
        26 => "^Z", // Substitute
        27 => "\\e", // Escape
        28 => "^\\", // File Separator
        29 => "^]", // Group Separator
        30 => "^^", // Record Separator
        31 => "^_", // Unit Separator
        127 => "\\DEL", // Delete
        else => &[_]u8{char}, // Default: return the character itself
    };
}

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
        if (err == error.FileNotFound) return false;
        return err;
    };

    return true;
}

fn checkIfUtf8(allocator: std.mem.Allocator, filePath: []const u8) !bool {
    const file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    var lines_to_read: u64 = 50;

    const bufferSize = try file.getEndPos();
    if (bufferSize == 0) return false;

    if (bufferSize < lines_to_read) lines_to_read = bufferSize;

    const data = try allocator.alloc(u8, lines_to_read);
    defer allocator.free(data);

    _ = try file.read(data[0..lines_to_read]); // Read up to 50 bytes from the file

    return std.unicode.utf8ValidateSlice(data);
}

// convert a full directory to a single Snippet file

// => convertDirectoryToSnippetFile (allocator, dir_path, output_file );

pub fn transformDir(
    dir_path: []const u8,
    output_file: []const u8,
) !usize {
    const allocator = std.heap.c_allocator;

    const grey_delimiter = "\x1b[37m*************************************************************\x1b[0m";
    const redCross = "\x1b[1m\x1b[31m✗\x1b[0m";
    const greenTick = "\x1b[1m\x1b[32m✓\x1b[0m";
    const end = "\x1b[0m";
    const bold = "\x1b[1m";
    const yellow = "\x1b[93m";
    const bright_green = "\x1b[92m";
    const bold_white = "\x1b[1m";

    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    if (try checkIfPathExists(output_file) == true) {
        try w.print("\nFile {s}{s}{s} Already Exists. {s}\nMust pass a new File.{s}\n", .{ bold_white, output_file, end, yellow, end });
        try buf.flush();
        return 0;
    }

    var new_file = std.fs.cwd().createFile(output_file, .{ .read = true }) catch |err| {
        try w.print("Failed Create output File:\nError:\x1b[31m{}\x1b[0m\n\n", .{err});
        try buf.flush();
        return 0;
    };

    defer new_file.close();

    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| {
        try w.print("Failed to Open Path Provided {s}\nError:\x1b[31m{}\x1b[0m\n\n", .{ dir_path, err });
        try buf.flush();
        return 0;
    };

    defer dir.close();

    var it = dir.iterate();

    var i: usize = 0;

    var isFirstSnippet = true;

    try w.print("{s}\n", .{grey_delimiter});

    while (try it.next()) |entry| {
        if (entry.kind != std.fs.File.Kind.file) continue;

        const dir_read_file = try concatStrings(allocator, dir_path, entry.name);
        defer allocator.free(dir_read_file);

        if (try checkIfUtf8(allocator, dir_read_file) == false) {
            try w.print(" {s} {s}{s}{s} ignored :{s} Non UTF data detected{s}\n", .{ redCross, bold, entry.name, end, yellow, end });
            continue;
        }

        var snippet = try Snippet.convertFileToSnippet(
            allocator,
            dir_read_file,
            false,
        );
        snippet.title = entry.name;

        defer snippet.destroy(allocator);

        if (isFirstSnippet) {
            try new_file.writeAll("{\n");
            isFirstSnippet = false;
        } else {
            try new_file.writeAll(",\n");
        }

        try snippet.appendSnippetFilePassed(new_file, false);

        try w.print(" {s} {s}{s}{s} Successfully Transformed\n", .{ greenTick, bold, entry.name, end });

        i += 1;
    }

    _ = try new_file.write("}");

    try w.print("\n{s}{d}{s} Snippets added to file {s}{s}{s}\n", .{ bold_white, i, end, bright_green, output_file, end });
    try w.print("{s}\n", .{grey_delimiter});

    try buf.flush();

    return i;
}

pub const output_file_not_exists = "\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mOutput Path Snippets File does not exist.\x1b[0m\n";
pub const msg_outputfile_missing = "\x1b[37mTo create a new file at the specificied location use the \x1b[1m-y\x1b[0m flag with \x1b[1m-o\x1b[0m.\x1b[0m\n\n\x1b[97m./vsfragment -f djikstras.md -o /users/code/dsa.code-snippets -y\x1b[0m";

// ******* snippet tests

test "Snippet convertDirectoryToSnippetFile Call" {
    const dir_path = "../tests/mock/backup/input";
    const output_file = "../tests/mock/backup/output/testing.code-snippets";

    const successul_files = try transformDir(dir_path, output_file);

    try std.testing.expectEqual(5, successul_files);

    try std.fs.cwd().deleteFile(output_file);
}

test "Snippet File Convert" {
    const allocator = std.testing.allocator;

    const file_name = "../tests/mock/testfile.txt";

    const snippet = try Snippet.convertFileToSnippet(allocator, file_name, true);
    const format_to_str = try std.fmt.allocPrint(allocator, "{s}", .{snippet});

    defer {
        for (snippet.body) |line| {
            allocator.free(line);
        }
        allocator.free(snippet.body);
        allocator.free(format_to_str);
    }
}

test "Snippet Direct Write File Convert" {
    const allocator = std.testing.allocator;

    const file_name = "../tests/mock/testfile.txt";
    const new_file_name = "../tests/mock/snippetcreate.code-snippets";

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

    const file_name = "../tests/mock/testfile.txt";
    const existing_file = "../tests/mock/snippetcreate.code-snippets";

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

test "Test Snippet Parse From Direct C String" {
    const mock_selection =
        \\hello
        \\world
        \\\\\\\\
        \\\n\n\n\n\n
        \\nextline nextline
        \\oneline \n\n    aaaa\\\\ \ttttt XXXX
        \\oneline \n\n    aaaa\\\\ \ttttt XXXX
        \\          \!!!!!,,,,,
        \\
        \\
    ;

    const allocator = std.testing.allocator;

    const cString: [*c]const u8 = "Your test string here";
    const cStringSlice: []const u8 = std.mem.span(cString);

    const split_s = try convertStringToStringSlice(allocator, cStringSlice);
    defer allocator.free(split_s);

    acceptStringSlicesConst(split_s);

    var sn1 = try Snippet.createFromString(allocator, mock_selection, false);

    var sn2 = try Snippet.createFromString(allocator, std.mem.span(cString), false);

    defer {
        sn1.destroy(allocator);
        sn2.destroy(allocator);
    }
    try std.testing.expect(true);
}

// ****** helpers

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

fn listFilesInDir(dirPath: []const u8) !void {
    var dir = try std.fs.cwd().openDir(dirPath, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        std.debug.print("File: {s}-{}\n", .{ entry.name, entry.kind });
    }
}

// ****** string utils

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
    var sz: usize = 0;

    sz += str_slices.len;

    for (str_slices) |st| {
        sz += st.len;
    }
}

// ****** json

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

    print("Parsed No Err\n", .{});

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
