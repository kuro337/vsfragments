const std = @import("std");
const print = std.debug.print;

const clap = @import("clap");

test "Test Zig Clap Module Usage" {
    print("Test Zig Clap Module Usage\n", .{});

    _ = clap.Diagnostic{};

    try std.testing.expect(true);
}

test "Test Print" {
    print("Test Zig Clap Module Usage\n", .{});

    try std.testing.expect(true);
}

// zig test file.zig

//  const clap_mod = b.addModule("clap", .{ .source_file = .{ .path = "../zig-clap/clap.zig" } });
