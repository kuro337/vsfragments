const std = @import("std");

const build_output_artifact_name = "zignapi";

const build_targets = [_]std.zig.CrossTarget{ .{}, .{
    .cpu_arch = .aarch64,
    .os_tag = .macos,
}, .{
    .cpu_arch = .x86_64,
    .os_tag = .linux,
}, .{
    .cpu_arch = .x86_64,
    .os_tag = .windows,
} };

const BuildConfig = struct {
    name: []const u8,
    optimize: std.builtin.OptimizeMode,
};

const build_configs = [_]BuildConfig{
    .{ .name = "fast", .optimize = .ReleaseFast },
    .{ .name = "safe", .optimize = .ReleaseSafe },
    .{ .name = "debug", .optimize = .Debug },
    .{ .name = "small", .optimize = .ReleaseSmall },
};

pub fn build(b: *std.build.Builder) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    for (build_targets) |target| {
        for (build_configs) |config| {
            const exe_name = try std.mem.concat(allocator, u8, &[_][]const u8{ build_output_artifact_name, "_", config.name });

            // =============== STATIC LIBRARY FOR C ===============

            const lib = b.addStaticLibrary(.{
                .name = exe_name,

                .root_source_file = .{ .path = "funcs.zig" },
                .target = target,
                .optimize = config.optimize,
            });

            b.installArtifact(lib);

            const target_output = b.addInstallArtifact(lib, .{
                .dest_dir = .{
                    .override = .{
                        .custom = try target.zigTriple(b.allocator),
                    },
                },
            });

            b.getInstallStep().dependOn(&target_output.step);
        }
    }
}
