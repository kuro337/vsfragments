const std = @import("std");
const print = std.debug.print;

test "C Strings" {}

test "C String Termination" {
    const allocator = std.heap.page_allocator;
    var buffer = try allocator.alloc(u8, 4);
    defer allocator.free(buffer);

    buffer[0] = 't';
    buffer[1] = 'e';
    buffer[2] = 's';
    buffer[3] = 0; // Null-terminator

    const cStr = @as([*:0]const u8, @ptrCast(&buffer[0]));
    std.testing.expectEqualStrings("tes", @as([*]const u8, @ptrCast(cStr)));
}

test "Buffer to String" {
    const allocator = std.heap.page_allocator;
    const str = "test";
    const buf = allocator.alloc(u8, str.len + 1) catch unreachable;
    defer allocator.free(buf);

    @memcpy(buf, str);

    buf[str.len] = 0; // Null-terminator

    const resultStr = @as([*:0]const u8, @ptrCast(buf));
    std.testing.expectEqualStrings(str, @as([*]const u8, @ptrCast(resultStr)));
}

test "String Writing" {
    const allocator = std.heap.page_allocator;
    var out = std.ArrayList(u8).initCapacity(allocator, 100) catch unreachable;
    defer out.deinit();

    try out.writer().writeAll("Hello, World!");
    std.testing.expectEqualStrings("Hello, World!", @as([*]const u8, @ptrCast(out.toOwnedSlice().ptr)));
}
