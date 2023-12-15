const std = @import("std");

const test_targets = [_]std.zig.CrossTarget{
    .{},
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

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

// =================== BUILD ===================

pub fn build(b: *std.Build) void {
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

    // =================== BINARIES ===================

    const exe = b.addExecutable(.{
        .name = "vsznippet-fast",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseFast,
    });

    //addZigClapFromSource(b, exe);
    addCommonModules(b, exe);
    b.installArtifact(exe);

    const exe_safe = b.addExecutable(.{
        .name = "vsznippet-safe",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseSafe,
    });

    //addZigClapFromSource(b, exe_safe);
    addCommonModules(b, exe_safe);
    b.installArtifact(exe_safe);

    const exe_debug = b.addExecutable(.{
        .name = "vsznippet-debug",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .Debug,
    });

    //addZigClapFromSource(b, exe_debug);
    addCommonModules(b, exe_debug);
    b.installArtifact(exe_debug);

    const exe_small = b.addExecutable(.{
        .name = "vsznippet-small",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseSmall,
    });

    //addZigClapFromSource(b, exe_small);
    addCommonModules(b, exe_small);
    b.installArtifact(exe_small);
}

// $ zig build test --summary all

// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin && ./vsznippet-safe

// Optimization Options  between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall

// zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSmall --summary all
