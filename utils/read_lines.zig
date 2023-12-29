const std = @import("std");

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

pub fn readLinesFromFileC(filename: []const u8) ![][]const u8 {
    const allocator = std.heap.c_allocator;

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

test "Copy Memory" {
    const allocator = std.testing.allocator;

    const sourceLine = "Hello, Zig!"; // Source string

    // 1. Copy using allocator.alloc + @memcpy

    const line = sourceLine.ptr;
    const lineCopy = try allocator.alloc(u8, sourceLine.len);
    @memcpy(lineCopy, line);

    try std.testing.expectEqualStrings(sourceLine, lineCopy[0..sourceLine.len]);

    // 2. Using allocator.dupe() which uses alloc() + @memcpy under the hood

    const line_dupe = try allocator.dupe(u8, sourceLine);
    try std.testing.expectEqualStrings(sourceLine, line_dupe);

    // Need to free memory we allocated
    allocator.free(lineCopy);
    allocator.free(line_dupe);
}
