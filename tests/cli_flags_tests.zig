const std = @import("std");
const print = std.debug.print;

const clap = @import("clap");

test "Test Zig Clap Module Usage" {
    _ = clap.Diagnostic{};

    try std.testing.expect(true);
}

test "Test Print" {
    try std.testing.expect(true);
}
