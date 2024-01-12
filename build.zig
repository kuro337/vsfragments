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

pub fn build(b: *Build) !void {
    const base_target = b.standardTargetOptions(.{});

    const test_step = b.step("test", "Run unit tests");

    const unit_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/unit_tests.zig" }, .target = base_target });
    const enum_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/enum_tests.zig" }, .target = base_target });
    const json_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/json_tests.zig" }, .target = base_target });
    const parsing_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/parsing_tests.zig" }, .target = base_target });
    const cli_flag_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/cli_flags_tests.zig" }, .target = base_target });
    const metadata_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/metadata_tests.zig" }, .target = base_target });
    const strconv_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/str_conv_tests.zig" }, .target = base_target });
    const reader_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/reader_tests.zig" }, .target = base_target });
    const union_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/union_tests.zig" }, .target = base_target });
    const read_dir_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/read_dir.zig" }, .target = base_target });
    const c_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/c_tests.zig" }, .target = base_target });
    const batch_tests = b.addTest(.{ .root_source_file = .{ .path = "tests/batch_write_tests.zig" }, .target = base_target });

    const run_enum_tests = b.addRunArtifact(enum_tests);
    const run_c_tests = b.addRunArtifact(c_tests);
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const run_json_tests = b.addRunArtifact(json_tests);
    const run_parse_tests = b.addRunArtifact(parsing_tests);
    const run_cli_tests = b.addRunArtifact(cli_flag_tests);
    const run_strconv_tests = b.addRunArtifact(strconv_tests);
    const run_reader_tests = b.addRunArtifact(reader_tests);
    const run_metadata_tests = b.addRunArtifact(metadata_tests);
    const run_union_tests = b.addRunArtifact(union_tests);
    const run_read_dir_tests = b.addRunArtifact(read_dir_tests);
    const run_batch_tests = b.addRunArtifact(batch_tests);

    addCommonModules(b, cli_flag_tests);
    addCommonModules(b, parsing_tests);
    addCommonModules(b, unit_tests);
    addCommonModules(b, batch_tests);

    test_step.dependOn(&run_unit_tests.step);
    test_step.dependOn(&run_c_tests.step);
    test_step.dependOn(&run_enum_tests.step);
    test_step.dependOn(&run_json_tests.step);
    test_step.dependOn(&run_cli_tests.step);
    test_step.dependOn(&run_metadata_tests.step);
    test_step.dependOn(&run_union_tests.step);
    test_step.dependOn(&run_strconv_tests.step);
    test_step.dependOn(&run_reader_tests.step);
    test_step.dependOn(&run_parse_tests.step);
    test_step.dependOn(&run_read_dir_tests.step);
    test_step.dependOn(&run_batch_tests.step);

    for (ARCH) |arch| {
        for (OS) |os| {
            for (MODE) |optimization| {
                var resolved_target = base_target;
                resolved_target.result.cpu.arch = arch;
                resolved_target.result.os.tag = os;

                const exe = b.addExecutable(.{
                    .name = "vsfragment",
                    .root_source_file = .{ .path = "main.zig" },
                    .optimize = optimization,
                    .target = resolved_target,
                });

                addCommonModules(b, exe);

                exe.linkLibC();

                const cpuarch = @tagName(arch);
                const osystem = @tagName(os);
                const release = @tagName(optimization);

                const target_output = b.addInstallArtifact(
                    exe,
                    .{ .dest_dir = .{ .override = .{
                        .custom = try std.fmt.allocPrint(b.allocator, "bin/{s}/{s}/{s}", .{ osystem, cpuarch, release }),
                    } } },
                );

                b.getInstallStep().dependOn(&target_output.step);
            }
        }
    }
}

fn addCommonModules(b: *Build, exe: *CompileStep) void {
    const read_lines = b.addModule("read_lines", .{ .root_source_file = .{ .path = "utils/read_lines.zig" } });
    const coord = b.addModule("coord", .{ .root_source_file = .{ .path = "structs/coord.zig" } });
    const memory_mgmt = b.addModule("memory_mgmt", .{ .root_source_file = .{ .path = "utils/memory_mgmt.zig" } });
    const constants = b.addModule("constants", .{ .root_source_file = .{ .path = "constants/cli_constants.zig" } });

    const timestamp = b.addModule("timestamp", .{ .root_source_file = .{ .path = "utils/time/timestamp.zig" } });
    const snippet = b.addModule("snippet", .{ .root_source_file = .{ .path = "structs/snippet.zig" }, .imports = &.{.{ .name = "timestamp", .module = timestamp }} });
    const json_parser = b.createModule(.{
        .root_source_file = .{ .path = "core/json_parser.zig" },
        .imports = &.{
            .{ .name = "snippet", .module = snippet },
            .{ .name = "memory_mgmt", .module = memory_mgmt },
            .{ .name = "read_lines", .module = read_lines },
            .{ .name = "constants", .module = constants },
        },
    });

    const flags = b.addModule("flags", .{
        .root_source_file = .{ .path = "structs/flags.zig" },
        .imports = &.{.{ .name = "constants", .module = constants }},
    });

    const write_results = b.addModule("write_results", .{ .root_source_file = .{ .path = "utils/write_results.zig" }, .imports = &.{
        .{ .name = "snippet", .module = snippet },
        .{ .name = "constants", .module = constants },
    } });

    const clap = b.addModule("clap", .{
        .root_source_file = .{ .path = "../zig-clap/clap.zig" },
    });

    const modify_snippet = b.addModule("modify_snippet", .{
        .root_source_file = .{ .path = "core/modify_snippet.zig" },
        .imports = &.{ .{ .name = "snippet", .module = snippet }, .{ .name = "memory_mgmt", .module = memory_mgmt }, .{ .name = "constants", .module = constants } },
    });

    const create_file = b.addModule("create_file", .{
        .root_source_file = .{ .path = "utils/create_file.zig" },
        .imports = &.{ .{ .name = "snippet", .module = snippet }, .{ .name = "constants", .module = constants } },
    });

    const cli_parser = b.addModule("cli_parser", .{
        .root_source_file = .{ .path = "core/cli_parser.zig" },
        .imports = &.{ .{ .name = "clap", .module = clap }, .{ .name = "flags", .module = flags }, .{ .name = "memory_mgmt", .module = memory_mgmt }, .{ .name = "constants", .module = constants } },
    });

    exe.root_module.addImport("flags", flags);
    exe.root_module.addImport("cli_parser", cli_parser);
    exe.root_module.addImport("flags", flags);
    exe.root_module.addImport("snippet", snippet);
    exe.root_module.addImport("coord", coord);
    exe.root_module.addImport("read_lines", read_lines);
    exe.root_module.addImport("memory_mgmt", memory_mgmt);
    exe.root_module.addImport("json_parser", json_parser);
    exe.root_module.addImport("modify_snippet", modify_snippet);
    exe.root_module.addImport("cli_parser", cli_parser);
    exe.root_module.addImport("clap", clap);
    exe.root_module.addImport("constants", constants);
    exe.root_module.addImport("write_results", write_results);
    exe.root_module.addImport("create_file", create_file);
}
