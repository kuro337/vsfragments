const std = @import("std");

const build_targets = [_]std.zig.CrossTarget{
    .{},
    //.{
    //     .cpu_arch = .aarch64,
    //     .os_tag = .macos,
    // }, .{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    // }, .{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .windows,
    // }
};

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

    // =================== BINARIES for TARGET + OPTIMIZATION_MODE ===================

    for (build_targets) |target| {
        const exe_target_triple = try target.zigTriple(b.allocator);

        const bin_path = std.fmt.allocPrint(b.allocator, "bin/{s}", .{exe_target_triple}) catch "format failed";
        _ = bin_path;
        const lib_path = std.fmt.allocPrint(b.allocator, "lib/{s}", .{exe_target_triple}) catch "format failed";

        for (build_configs) |config| {
            const exe_name = try std.mem.concat(allocator, u8, &[_][]const u8{ "vsfragment_cexports", "_", config.name });

            // const exe = b.addExecutable(.{
            //     .name = exe_name,
            //     .root_source_file = .{ .path = "main.zig" },
            //     .optimize = config.optimize,
            //     .target = target,
            // });

            // addCommonModules(b, exe);

            // const target_output = b.addInstallArtifact(exe, .{
            //     .dest_dir = .{
            //         .override = .{
            //             .custom = bin_path,
            //         },
            //     },
            // });

            // b.getInstallStep().dependOn(&target_output.step);

            // =============== STATIC LIBRARY FOR C ===============

            const lib = b.addStaticLibrary(.{
                .name = exe_name,

                .root_source_file = .{ .path = "parse_file_c.zig" },
                .target = target,
                .optimize = config.optimize,
            });

            addCommonModules(b, lib);

            const target_output_clib = b.addInstallArtifact(lib, .{
                .dest_dir = .{
                    .override = .{ .custom = lib_path },
                },
            });

            b.getInstallStep().dependOn(&target_output_clib.step);
        }
    }
}

// =================== MODULES ===================

fn addCommonModules(b: *std.Build, exe: *std.build.LibExeObjStep) void {
    const snippet = b.addModule("snippet", .{ .source_file = .{ .path = "../structs/snippet.zig" } });
    const read_lines = b.addModule("read_lines", .{ .source_file = .{ .path = "../utils/read_lines.zig" } });

    const memory_mgmt = b.addModule("memory_mgmt", .{ .source_file = .{ .path = "../utils/memory_mgmt.zig" } });
    const constants = b.addModule("constants", .{ .source_file = .{ .path = "../constants/cli_constants.zig" } });

    const modify_snippet = b.addModule("modify_snippet", .{
        .source_file = .{ .path = "../core/modify_snippet.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "constants", .module = constants },
        },
    });

    const create_file = b.addModule("create_file", .{
        .source_file = .{ .path = "../utils/create_file.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "constants", .module = constants },
        },
    });

    const json_parser = b.createModule(.{
        .source_file = .{ .path = "../core/json_parser.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "read_lines", .module = read_lines },
            .{ .name = "constants", .module = constants },
        },
    });

    const write_results = b.addModule("write_results", .{
        .source_file = .{ .path = "../utils/write_results.zig" },
        .dependencies = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "constants", .module = constants },
        },
    });

    //     modify_snippet
    //     create_file
    //     json_parser
    //     write_results

    // const parse_file_c = b.addModule("parse_file_c", .{
    //     .source_file = .{ .path = "parse_file_c.zig" },
    //     .dependencies = &.{
    //         .{ .name = "constants", .module = constants },
    //         .{ .name = "modify_snippet", .module = modify_snippet },
    //         .{ .name = "create_file", .module = create_file },
    //         .{ .name = "json_parser", .module = json_parser },
    //         .{ .name = "write_results", .module = write_results },
    //         .{ .name = "snippet", .module = snippet },
    //         .{ .name = "read_lines", .module = read_lines },
    //         .{ .name = "memory_mgmt", .module = memory_mgmt },
    //     },
    // });

    //    exe.addModule("parse_file_c", parse_file_c);

    exe.addModule("modify_snippet", modify_snippet);
    exe.addModule("create_file", create_file);
    exe.addModule("json_parser", json_parser);
    exe.addModule("write_results", write_results);

    //exe.addModule("flags", flags);
    exe.addModule("snippet", snippet);
    // exe.addModule("coord", coord);
    exe.addModule("read_lines", read_lines);
    exe.addModule("memory_mgmt", memory_mgmt);
    exe.addModule("constants", constants);
}

// $ zig build test --summary all
// $ zig build test --summary failures

// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && ./vsfragment_safe

// Optimization Options  between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall

// zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSmall --summary all

// Print File Architecture ARM or x86_64
// file filename
