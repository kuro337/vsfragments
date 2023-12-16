const std = @import("std");

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

const test_targets = [_]std.zig.CrossTarget{ .{}, .{
    .cpu_arch = .aarch64,
    .os_tag = .macos,
} };

// =================== BUILD ===================

pub fn build(b: *std.Build) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const test_step = b.step("test", "Run unit tests");

    for (test_targets) |target| {
        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = "tests/unit_tests.zig" },
            .target = target,
        });

        // =================== UNIT TESTS ===================

        addCommonModules(b, unit_tests);

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);

        // =================== READ + PARSING TESTS ===================
        const read_parse_tests = b.addTest(.{
            .root_source_file = .{ .path = "tests/read_parse_test.zig" },
            .target = target,
        });

        addCommonModules(b, read_parse_tests);

        const run_read_parse_tests = b.addRunArtifact(read_parse_tests);
        test_step.dependOn(&run_read_parse_tests.step);

        // =================== CLI PARSING TESTS ===================
        const cli_parsing_tests = b.addTest(.{
            .root_source_file = .{ .path = "tests/cli_flags_tests.zig" },
            .target = target,
        });

        addCommonModules(b, cli_parsing_tests);
        //addZigClapFromSource(b, cli_parsing_tests);

        const run_cli_parsing_tests = b.addRunArtifact(cli_parsing_tests);
        test_step.dependOn(&run_cli_parsing_tests.step);
    }

    // =================== BINARIES for TARGET + OPTIMIZATION_MODE ===================

    for (build_targets) |target| {
        for (build_configs) |config| {
            const exe_name = try std.mem.concat(allocator, u8, &[_][]const u8{ "vsfragment", "_", config.name });

            const exe = b.addExecutable(.{
                .name = exe_name,
                .root_source_file = .{ .path = "main.zig" },
                .optimize = config.optimize,
                .target = target,
            });

            addCommonModules(b, exe);

            const target_output = b.addInstallArtifact(exe, .{
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

// =================== MODULES ===================

fn addCommonModules(b: *std.Build, exe: *std.build.LibExeObjStep) void {
    const flags = b.addModule("flags", .{ .source_file = .{ .path = "structs/flags.zig" } });
    const snippet = b.addModule("snippet", .{ .source_file = .{ .path = "structs/snippet.zig" } });
    const read_lines = b.addModule("read_lines", .{ .source_file = .{ .path = "utils/read_lines.zig" } });
    const coord = b.addModule("coord", .{ .source_file = .{ .path = "structs/coord.zig" } });
    const memory_mgmt = b.addModule("memory_mgmt", .{ .source_file = .{ .path = "utils/memory_mgmt.zig" } });

    const clap = b.addModule("clap", .{ .source_file = .{ .path = "../zig-clap/clap.zig" } });

    const json_parser = b.createModule(.{
        .source_file = .{ .path = "core/json_parser.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "read_lines", .module = read_lines },
        },
    });

    const modify_snippet = b.addModule("modify_snippet", .{
        .source_file = .{ .path = "core/modify_snippet.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
        },
    });

    const cli_parser = b.addModule("cli_parser", .{
        .source_file = .{ .path = "core/cli_parser.zig" },
        .dependencies = &.{
            .{ .name = "clap", .module = clap },
            .{ .name = "flags", .module = flags },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
        },
    });

    exe.addModule("flags", flags);
    exe.addModule("snippet", snippet);
    exe.addModule("coord", coord);
    exe.addModule("read_lines", read_lines);
    exe.addModule("memory_mgmt", memory_mgmt);
    exe.addModule("json_parser", json_parser);
    exe.addModule("modify_snippet", modify_snippet);
    exe.addModule("cli_parser", cli_parser);
    exe.addModule("clap", clap);
}

// $ zig build test --summary all

// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && ./vsfragment_safe

// Optimization Options  between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall

// zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSmall --summary all

// Print File Architecture ARM or x86_64
// file filename
