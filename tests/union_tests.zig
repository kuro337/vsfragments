const std = @import("std");

const Build = std.Build;
const CompileStep = std.Build.Step.Compile;

const application = "vsfragment";

const architectures = enum {
    aarch64,
    x86_64,
};

const osystems = enum {
    macos,
    linux,
    windows,
};

pub const Config = struct {
    arch: architectures,
    os: osystems,
};

pub const BuildConfig = struct {
    arch: std.Target.Cpu.Arch,
    os: std.Target.Os.Tag,
};

const targets = [_]BuildConfig{
    BuildConfig{
        .arch = std.Target.Cpu.Arch.aarch64,
        .os = std.Target.Os.Tag.macos,
    },
    BuildConfig{
        .arch = std.Target.Cpu.Arch.x86_64,
        .os = std.Target.Os.Tag.macos,
    },
};

const Optimization = struct {
    name: []const u8,
    optimize: std.builtin.OptimizeMode,
};

const modes = [_]Optimization{
    .{ .name = "fast", .optimize = .ReleaseFast },
    .{ .name = "safe", .optimize = .ReleaseSafe },
    .{ .name = "debug", .optimize = .Debug },
    .{ .name = "small", .optimize = .ReleaseSmall },
};

const test_targets = [_]BuildConfig{
    BuildConfig{
        .arch = std.Target.Cpu.Arch.aarch64,
        .os = std.Target.Os.Tag.macos,
    },
};

test "Test Build Configs" {
    const linux = Config{ .arch = architectures.aarch64, .os = osystems.linux };
    const mac = Config{ .arch = architectures.aarch64, .os = osystems.macos };
    const win = Config{ .arch = architectures.x86_64, .os = osystems.windows };

    try std.testing.expectEqual(mac.arch, architectures.aarch64);
    try std.testing.expectEqual(mac.os, osystems.macos);

    try std.testing.expectEqual(win.arch, architectures.x86_64);
    try std.testing.expectEqual(win.os, osystems.windows);

    try std.testing.expectEqual(linux.arch, architectures.aarch64);
    try std.testing.expectEqual(linux.os, osystems.linux);

    try std.testing.expect(true);
}

const StrTypes = enum { c_str, c_str_alt, zig_str };

const CZigString = union(StrTypes) {
    c_str: [*:0]const u8,
    c_str_alt: [*c]const u8,
    zig_str: []const u8,
};

pub fn testUnion(p: CZigString) void {
    switch (p) {
        CZigString.c_str => std.debug.print("C String Passed [*:0]const u8\n", .{}),
        CZigString.c_str_alt => std.debug.print("C String Passed [*c]const u8\n", .{}),
        CZigString.zig_str => std.debug.print("Zig String Passed []const u8\n", .{}),
    }
}

// zig build-exe c_zig_string.zig
// ./c_zig_string
// zig test file.zig
