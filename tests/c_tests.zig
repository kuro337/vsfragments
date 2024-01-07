const std = @import("std");
const print = std.debug.print;

test "C Strings" {}

test "C String Termination" {
    const allocator = std.testing.allocator;
    var buffer = try allocator.alloc(u8, 4);
    defer allocator.free(buffer);

    buffer[0] = 't';
    buffer[1] = 'e';
    buffer[2] = 's';
    buffer[3] = 0; // Null-terminator

    const cStr = @as([*:0]const u8, @ptrCast(&buffer[0]));
    try std.testing.expectEqualStrings("tes", cStr[0..3]);
}

test "Buffer to String" {
    const str = "test";

    const resultStr = @as([*:0]const u8, @ptrCast(str));

    try std.testing.expectEqualStrings("test", resultStr[0..str.len]);
}

test "String Writing" {
    const allocator = std.testing.allocator;
    var out = std.ArrayList(u8).initCapacity(allocator, 100) catch unreachable;
    defer out.deinit();

    try out.writer().writeAll("Hello, World!");
    const slice = try out.toOwnedSlice();
    defer allocator.free(slice);

    try std.testing.expectEqualStrings("Hello, World!", slice[0..slice.len]);
}
