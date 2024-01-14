const std = @import("std");
const cString = @cImport({
    @cInclude("string.h");
});

// **** c exposed methods

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn testWriteSampleFile() u8 {
    return writeToDiskNoErr();
}

export fn writeFileCurrPath(file_path: [*c]const u8) u8 {
    const zig_file_path = std.mem.span(file_path);

    return writeToPath(zig_file_path);
}

export fn writeFileToPathAbs(file_path: [*c]const u8) u8 {
    const zig_file_path = std.mem.span(file_path);

    return writeFileAbsoluteImpl(zig_file_path);
}

export fn getPath(file_path: [*c]const u8) [*c]const u8 {
    const zig_file_path = std.mem.span(file_path);

    return getCurrPath(zig_file_path);
}

pub fn writeToDiskNoErr() u8 {
    _ = writeToDiskFromNode() catch |err| {
        std.debug.print("Error Writing File: {}\n", .{err});
        return 1;
    };
    std.debug.print("No Err Write\n", .{});

    return 0;
}

pub fn writeToPath(file_path: []const u8) u8 {
    _ = writeToPathNode(file_path) catch |err| {
        std.debug.print("Failed Writing To File: {}\n", .{err});
        return 1;
    };
    std.debug.print("Success Writing To File: {s}\n", .{file_path});

    return 0;
}

pub fn getCurrPath(file_path: []const u8) [*c]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const allocator = arena.allocator();

    const abs_path = getAbsolutePathCurrDir(allocator, file_path) catch |err| {
        std.debug.print("Error Getting Curr Path: {}\n", .{err});
        return null;
    };

    return abs_path.ptr;
}

pub fn writeFileAbsoluteImpl(file_path: []const u8) u8 {
    _ = writeToPathAbs(file_path) catch |err| {
        std.debug.print("Failed Writing To File:{s} ERR:{}\n", .{ file_path, err });
        return 1;
    };
    std.debug.print("Success Writing To File: {s}\n", .{file_path});

    return 0;
}

pub fn writeToPathNode(file_path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const abs_full_path = try getAbsolutePathCurrDir(allocator, file_path);

    defer allocator.free(abs_full_path);

    std.debug.print("Full Abs Path: {s}\n", .{abs_full_path});

    var data = [_][]const u8{
        "hello",
        "world",
    };

    try writeStringsNewFile(abs_full_path, &data);
    try writeStringsToExistingFile(abs_full_path, &data);
}

pub fn writeToPathAbs(file_path: []const u8) !void {
    std.debug.print("writeToPathAbs() called with: {s}\n", .{file_path});

    var data = [_][]const u8{
        "hello",
        "world",
    };

    try writeStringsNewFile(file_path, &data);
}

pub fn writeToDiskFromNode() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    _ = allocator;

    const file_path = "node_file.txt";
    _ = file_path;

    const abs_full_path = "somepath/";

    std.debug.print("Full Abs Path: {s}\n", .{abs_full_path});

    var data = [_][]const u8{
        "hello",
        "world",
    };

    try writeStringsNewFile(abs_full_path, &data);
    try writeStringsToExistingFile(abs_full_path, &data);
}

pub fn getAbsolutePath(
    allocator: std.mem.Allocator,
) ![]u8 {
    const abs_path = try std.fs.cwd().realpathAlloc(allocator, ".");
    return abs_path;
}

pub fn writeStringsToExistingFile(file_path: []const u8, data: [][]const u8) !void {
    std.debug.print("Write Test Second Call\n", .{});

    // Open the file
    const file = try std.fs.openFileAbsolute(file_path, .{ .mode = .read_write });
    defer file.close();

    std.debug.print("Success Opening Absolute Test Second Call\n", .{});

    const file_end_pos = try file.getEndPos();
    std.debug.print("file end pos {d}\n", .{file_end_pos});

    try file.seekTo(file_end_pos);

    for (data) |line| {
        _ = try file.write(line);
        _ = try file.write("\n");
    }
    std.debug.print("Success Write Test Second Call\n", .{});
}

pub fn writeStringsNewFile(file_path: []const u8, data: [][]const u8) !void {
    std.debug.print("Write Test First Call\n", .{});

    const file = try std.fs.createFileAbsolute(file_path, .{});
    defer file.close();

    const file_end_pos = try file.getEndPos();
    std.debug.print("file end pos {d}\n", .{file_end_pos});

    try file.seekTo(file_end_pos);

    for (data) |line| {
        _ = try file.write(line);
        _ = try file.write("\n");
    }

    std.debug.print("Success Write Test First Call\n", .{});
}

pub fn getAbsolutePathCurrDir(allocator: std.mem.Allocator, new_file_path: []const u8) ![]u8 {
    const abs_path = try getAbsolutePath(allocator);
    defer allocator.free(abs_path);

    var combinedPath = try allocator.alloc(u8, abs_path.len + new_file_path.len + 1); // +1 for null terminator if needed

    @memcpy(combinedPath[0..abs_path.len], abs_path);

    combinedPath[abs_path.len] = '/';

    @memcpy(combinedPath[abs_path.len + 1 ..], new_file_path);
    return combinedPath;
}

pub fn writeToDiskNoErrtt() u8 {
    _ = writeToDiskFromNode() catch {
        return 1;
    };
    return 0;
}

fn strdup(allocator: std.mem.Allocator, str: [:0]const u8) ![:0]u8 {
    const cCopy: [*:0]u8 = cString.strdup(str) orelse return error.OutOfMemory;
    defer std.c.free(cCopy);
    const zCopy: [:0]u8 = std.mem.span(cCopy);
    return allocator.dupeZ(u8, zCopy);
}

fn strdupZigToC(allocator: std.mem.Allocator, str: []const u8) ![:0]u8 {
    var buffer = try allocator.alloc(u8, str.len + 1);

    @memcpy(buffer, str);
    buffer[str.len] = 0;
    return buffer[0..str.len :0];
}
