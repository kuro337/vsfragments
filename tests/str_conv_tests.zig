const std = @import("std");

test "Create a String" {
    const s = "Hello World Zig Test";

    const split_s = try convertStringToStringSlice(std.testing.allocator, s);
    defer std.testing.allocator.free(split_s);

    acceptStringSlices(split_s);
    _ = try std.testing.expect(true);

    acceptStringSlicesConst(split_s);
    _ = try std.testing.expect(true);
}

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
    for (str_slices) |st| {
        _ = st; // autofix

        //     std.debug.print("{s}", .{st});
    }
}

pub fn acceptStringSlices(str_slices: [][]const u8) void {
    for (str_slices) |st| {
        _ = st; // autofix

        //        std.debug.print("{s}", .{st});
    }
}

// zig test str_conv_tests.zig
