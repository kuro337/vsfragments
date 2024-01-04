const std = @import("std");

const absolute_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/";

test "Read Func with newline" {
    const allocator = std.testing.allocator;

    const INPUT_FILE_PATH = absolute_path ++ "tests/MOCK_PARSER_DATA/inline/input.txt";

    const lines = try readLinesFromFile(allocator, INPUT_FILE_PATH);
    const full_file_content = try readFile(allocator, INPUT_FILE_PATH);
    const inline_lines = try convertInlineCodeToLines(allocator, full_file_content);

    defer {
        for (lines) |line| {
            allocator.free(line);
        }
        allocator.free(lines);
        allocator.free(full_file_content);
        allocator.free(inline_lines);
    }

    for (lines, 0..) |line, i| {
        try std.testing.expectEqualStrings(line, inline_lines[i]);
    }
}

test "inline test" {
    const allocator = std.testing.allocator;
    const INPUT_FILE_PATH = absolute_path ++ "tests/MOCK_PARSER_DATA/inline/input.txt";

    const full_file_content = try readFile(allocator, INPUT_FILE_PATH);
    defer allocator.free(full_file_content);

    const inline_lines = try convertInlineCodeToLines(allocator, full_file_content);
    defer allocator.free(inline_lines);

    // for (inline_lines) |line| {
    //     std.debug.print("{s}\n", .{line});
    // }
    try std.testing.expect(true);
}

pub fn convertInlineCodeToLines(allocator: std.mem.Allocator, code_str: []const u8) ![][]const u8 {
    var splitLines = std.ArrayList([]const u8).init(allocator);
    defer splitLines.deinit();

    var split = std.mem.splitScalar(u8, code_str, '\n');

    while (split.next()) |line| {
        try splitLines.append(line);
    }

    return splitLines.toOwnedSlice();
}

pub fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // Determine the file size
    const fileSize = try file.getEndPos();

    // Allocate a buffer to hold the file content
    const buffer = try allocator.alloc(u8, fileSize);
    // defer allocator.free(buffer);

    // Read the file content into the buffer
    _ = try file.readAll(buffer);

    return buffer;
}

pub fn readLinesFromFile(allocator: std.mem.Allocator, filename: []const u8) ![][]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // Gets passed a filename - read each line to an ArrayList

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var buf: [1024]u8 = undefined; //1024 bytes or 1kb

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
    }

    return lines.toOwnedSlice();
}

// zig build-exe vector.zig
// ./vector
// zig test file.zig
