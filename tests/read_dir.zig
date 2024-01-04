const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try listFilesInDir(allocator, ".");
    try listFilesInDir(allocator, "/Users/kuro/Documents/Code/Zig/FileIO/file");
}

fn listFilesInDir(allocator: std.mem.Allocator, dirPath: []const u8) !void {
    _ = allocator; // autofix
    var dir = try std.fs.cwd().openDir(dirPath, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        //entry.name
        // const file_name = try entry.getName(allocator);
        // defer allocator.free(file_name);

        std.debug.print("File: {s}\n", .{entry.name});
    }
}

test "Read Dir" {
    const allocator = std.testing.allocator;
    try listFilesInDir(allocator, ".");
}
