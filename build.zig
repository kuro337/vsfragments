const std = @import("std");

const test_targets = [_]std.zig.CrossTarget{
    .{},
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

// =================== MODULES ===================

fn addCommonModules(b: *std.Build, zig_test: *std.build.LibExeObjStep) void {
    const json_parser = b.addModule("json_parser", .{ .source_file = .{ .path = "json_parser.zig" } });
    const snippet = b.addModule("structs", .{ .source_file = .{ .path = "structs/snippet.zig" } });
    const coord = b.addModule("structs", .{ .source_file = .{ .path = "structs/coord.zig" } });

    const checkMemoryLeaks = b.addModule("checkMemoryLeaks", .{ .source_file = .{ .path = "utils/memory_mgmt.zig" } });
    const clearSliceMatrixMemory = b.addModule("clearSliceMatrixMemory", .{ .source_file = .{ .path = "utils/memory_mgmt.zig" } });
    const readLinesFromFile = b.addModule("readLinesFromFile", .{ .source_file = .{ .path = "utils/read_lines.zig" } });

    zig_test.addModule("json_parser", json_parser);
    zig_test.addModule("snippet", snippet);
    zig_test.addModule("coord", coord);
    zig_test.addModule("checkMemoryLeaks", checkMemoryLeaks);
    zig_test.addModule("clearSliceMatrixMemory", clearSliceMatrixMemory);
    zig_test.addModule("readLinesFromFile", readLinesFromFile);
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
    }

    // =================== BINARIES ===================

    const exe = b.addExecutable(.{
        .name = "vsznippet-fast",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseFast,
    });

    b.installArtifact(exe);

    const exe_safe = b.addExecutable(.{
        .name = "vsznippet-safe",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseSafe,
    });

    b.installArtifact(exe_safe);

    const exe_debug = b.addExecutable(.{
        .name = "vsznippet-debug",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .Debug,
    });

    b.installArtifact(exe_debug);

    const exe_small = b.addExecutable(.{
        .name = "vsznippet-small",
        .root_source_file = .{ .path = "main.zig" },
        .optimize = .ReleaseSmall,
    });

    b.installArtifact(exe_small);
}

// $ zig build test --summary all

// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/parser/zig-out/bin && ./vsznippet-safe

// Optimization Options  between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall

// zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSmall --summary all
