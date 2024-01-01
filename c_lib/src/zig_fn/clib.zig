const std = @import("std");
const cString = @cImport({
    @cInclude("string.h");
});

// Building Static C Lib
// zig build
// npm install
// zig build-lib funcs  .zig -static

// Build + Run System Binary
// zig build-exe funcs.zig
// ./funcs
// zig test file.zig

// =================== C EXPOSED FUNCTIONS ===================
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn getString() [*c]const u8 {
    const message = "Hello from Zig!";
    return message.ptr;
}

export fn testWriteSampleFile() u8 {
    return writeToDiskNoErr();
}

export fn writeFileCurrPath(file_path: [*c]const u8) u8 {
    const zig_file_path = std.mem.span(file_path);

    // Call writeToPath, which expects a Zig slice ([]const u8)
    return writeToPath(zig_file_path);
}

export fn writeFileToPathAbs(file_path: [*c]const u8) u8 {
    const zig_file_path = std.mem.span(file_path);

    // Call writeToPath, which expects a Zig slice ([]const u8)
    return writeFileAbsoluteImpl(zig_file_path);
}

export fn getPath(file_path: [*c]const u8) [*c]const u8 {
    const zig_file_path = std.mem.span(file_path);

    return getCurrPath(zig_file_path);
}

export fn processStringFromCJS(input: [*c]const u8) void {
    const inputString = std.mem.span(input);
    std.debug.print("String received in Zig from JS-C: {s}\n", .{inputString});
}

// =========================================================

// SAMPLE DISK WRITE CALLED HERE 0 success 1 Error
pub fn writeToDiskNoErr() u8 {
    _ = writeToDiskFromNode() catch |err| {
        std.debug.print("Error Writing File: {}\n", .{err});
        return 1;
    };
    std.debug.print("No Err Write\n", .{});

    return 0;
}

// 1. DISK_WRITE USING NODEAPP PATH 0 success 1 Error
pub fn writeToPath(file_path: []const u8) u8 {
    _ = writeToPathNode(file_path) catch |err| {
        std.debug.print("Failed Writing To File: {}\n", .{err});
        return 1;
    };
    std.debug.print("Success Writing To File: {s}\n", .{file_path});

    return 0;
}

// 2. GET_ABSOLUTE_PATH USING NODEAPP PATH -> C String
pub fn getCurrPath(file_path: []const u8) [*c]const u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //  defer arena.deinit();

    const allocator = arena.allocator();

    const abs_path = getAbsolutePathCurrDir(allocator, file_path) catch |err| {
        std.debug.print("Error Getting Curr Path: {}\n", .{err});
        return null;
    };

    return abs_path.ptr;
}

// 3. GET_ABSOLUTE_PATH USING NODEAPP PATH -> C String
pub fn writeFileAbsoluteImpl(file_path: []const u8) u8 {
    _ = writeToPathAbs(file_path) catch |err| {
        std.debug.print("Failed Writing To File:{s} ERR:{}\n", .{ file_path, err });
        return 1;
    };
    std.debug.print("Success Writing To File: {s}\n", .{file_path});

    return 0;
}

// =================== MAIN ===================

pub fn main() !void {
    //_ = testWriteSampleFile();
    const abs_full_path = "/Users/kuro/Documents/Code/JS/vsfragments/hellofrag/out/output/testfile.txt";
    try writeToPathAbs(abs_full_path);

    std.debug.print("No Err Main\n", .{});
}

// Function that Writes a Sample File
// Have this write the abs path to see where we wrote the output files

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

// Function that Writes a Sample File
pub fn writeToDiskFromNode() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    _ = allocator;

    const file_path = "node_file.txt";
    _ = file_path;

    // Hardcode path to Extension Output
    const abs_full_path = "/abs/path/testfile.txt";

    std.debug.print("Full Abs Path: {s}\n", .{abs_full_path});

    var data = [_][]const u8{
        "hello",
        "world",
    };

    try writeStringsNewFile(abs_full_path, &data);
    try writeStringsToExistingFile(abs_full_path, &data);
}

pub fn getAbsolutePath( // use getAbsolutePathCurrDir for path including file passed
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

    // Open the file
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

    // Allocate a new slice that can hold the combined contents.
    var combinedPath = try allocator.alloc(u8, abs_path.len + new_file_path.len + 1); // +1 for null terminator if needed

    // Copy the contents of `abs_path` and `new_file_path` into the new slice.
    std.mem.copy(u8, combinedPath[0..abs_path.len], abs_path);
    combinedPath[abs_path.len] = '/'; // Use the appropriate separator for your system

    std.mem.copy(u8, combinedPath[abs_path.len + 1 ..], new_file_path);

    return combinedPath;

    //============================================
    // For C-Style Strings add a \0 to terminate
    // Null-terminate the combined path if you plan to use it as a C-style string.
    // combinedPath[combinedPath.len - 1] = 0;
    // https://mtlynch.io/notes/zig-strings-call-c-code/
    //============================================

}

pub fn writeToDiskNoErrtt() u8 {
    _ = writeToDiskFromNode() catch {
        return 1;
    };
    return 0;
}

// Accept a C String

// can pass strings directly such as const convert_zig_str = "abcefgh"
fn strdup(allocator: std.mem.Allocator, str: [:0]const u8) ![:0]u8 {
    const cCopy: [*:0]u8 = cString.strdup(str) orelse return error.OutOfMemory;
    defer std.c.free(cCopy);
    const zCopy: [:0]u8 = std.mem.span(cCopy);
    return allocator.dupeZ(u8, zCopy);
}

// can pass strings that are returned from a function (const [] u8) and not null terminated

fn strdupZigToC(allocator: std.mem.Allocator, str: []const u8) ![:0]u8 {
    var buffer = try allocator.alloc(u8, str.len + 1);
    std.mem.copy(u8, buffer, str);
    buffer[str.len] = 0; // Null terminator
    return buffer[0..str.len :0]; // Correct slice
}
