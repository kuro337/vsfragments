const std = @import("std");

const CompileStep = std.Build.Step.Compile;
const Build = std.Build;
const Tag = std.Target.Os.Tag;
const Arch = std.Target.Cpu.Arch;
const OptimizeMode = std.builtin.OptimizeMode;

const OS = [_]Tag{
    Tag.macos, Tag.linux,
    //Tag.windows,
};

const ARCH = [_]Arch{ Arch.aarch64, Arch.x86_64 };
const MODE = [_]OptimizeMode{ .Debug, .ReleaseSafe, .ReleaseSmall, .ReleaseFast };

// pub fn build(b: *std.Build) !void {
//     const base_target = b.standardTargetOptions(.{});

//     for (ARCH) |arch| {
//         for (OS) |os| {
//             for (MODE) |optimization| {
//                 var resolved_target = base_target;
//                 resolved_target.result.cpu.arch = arch;
//                 resolved_target.result.os.tag = os;

//                 const lib = b.addStaticLibrary(.{
//                     .name = "vsfragment_cexports",
//                     .root_source_file = .{ .path = "parse_file_c.zig" },
//                     .optimize = optimization,
//                     .target = resolved_target,
//                 });

//                 lib.linkLibC();

//                 addCommonModules(b, lib);

//                 const cpuarch = @tagName(arch);
//                 const osystem = @tagName(os);
//                 const release = @tagName(optimization);

//                 const target_output_clib = b.addInstallArtifact(lib, .{
//                     .dest_dir = .{
//                         .override = .{
//                             .custom = try std.fmt.allocPrint(b.allocator, "lib/{s}/{s}/{s}", .{ osystem, cpuarch, release }),
//                         },
//                     },
//                 });

//                 b.getInstallStep().dependOn(&target_output_clib.step);
//             }
//         }
//     }
// }

// NATIVE ONLY - comment out above to run just native build

pub fn build(b: *std.Build) !void {
    const base_target = b.standardTargetOptions(.{});

    for (MODE) |optimization| {
        const resolved_target = base_target;

        const lib = b.addStaticLibrary(.{
            .name = "vsfragment_cexports",
            .root_source_file = .{ .path = "parse_file_c.zig" },
            .optimize = optimization,
            .target = resolved_target,
        });

        lib.linkLibC();

        addCommonModules(b, lib);

        const release = @tagName(optimization);

        const target_output_clib = b.addInstallArtifact(lib, .{
            .dest_dir = .{
                .override = .{
                    .custom = try std.fmt.allocPrint(b.allocator, "lib/{s}/{s}", .{ "native", release }),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output_clib.step);
    }
}

fn addCommonModules(b: *Build, exe: *CompileStep) void {
    const timestamp = b.addModule("timestamp", .{ .root_source_file = .{ .path = "../utils/time/timestamp.zig" } });
    const snippet = b.addModule("snippet", .{ .root_source_file = .{ .path = "../structs/snippet.zig" }, .imports = &.{.{ .name = "timestamp", .module = timestamp }} });
    const read_lines = b.addModule("read_lines", .{ .root_source_file = .{ .path = "../utils/read_lines.zig" } });
    const memory_mgmt = b.addModule("memory_mgmt", .{ .root_source_file = .{ .path = "../utils/memory_mgmt.zig" } });
    const constants = b.addModule("constants", .{ .root_source_file = .{ .path = "../constants/cli_constants.zig" } });
    const modify_snippet = b.addModule("modify_snippet", .{
        .root_source_file = .{ .path = "../core/modify_snippet.zig" },
        .imports = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "constants", .module = constants },
        },
    });

    const create_file = b.addModule("create_file", .{
        .root_source_file = .{ .path = "../utils/create_file.zig" },
        .imports = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "constants", .module = constants },
        },
    });

    const json_parser = b.createModule(.{
        .root_source_file = .{ .path = "../core/json_parser.zig" },
        .imports = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "read_lines", .module = read_lines },
            .{ .name = "constants", .module = constants },
        },
    });

    const write_results = b.addModule("write_results", .{
        .root_source_file = .{ .path = "../utils/write_results.zig" },
        .imports = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "constants", .module = constants },
        },
    });

    exe.root_module.addImport("modify_snippet", modify_snippet);
    exe.root_module.addImport("create_file", create_file);
    exe.root_module.addImport("json_parser", json_parser);
    exe.root_module.addImport("write_results", write_results);

    exe.root_module.addImport("snippet", snippet);

    exe.root_module.addImport("read_lines", read_lines);
    exe.root_module.addImport("memory_mgmt", memory_mgmt);
    exe.root_module.addImport("constants", constants);
}
