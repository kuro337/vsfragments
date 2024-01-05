const std = @import("std");
const print = std.debug.print;

const constants = @import("constants");

pub const FlagEval = enum(u8) {
    invalid,
    file,
    file_out,
    inline_code,
};

// use .? to coeerce type to remove Optional

pub const Flags = struct {
    file_path: ?[]const u8 = null,
    output_path: ?[]const u8 = null,
    code_str: ?[]const u8 = null,
    lang: ?[]const u8 = null,
    help: bool = false,
    print: bool = false,
    title: ?[]const u8 = null,
    description: ?[]const u8 = null,
    prefix: ?[]const u8 = null,
    confirmation: bool = false,
    force: bool = false,

    pub fn evalCmds(self: Flags) FlagEval {

        // passed no file or direct code
        if (self.file_path == null and self.code_str == null) {
            return FlagEval.invalid;
        }

        // passed file but no output
        if (self.file_path != null and self.output_path == null) {
            return FlagEval.file;
        }

        // passed file and output path
        if (self.file_path != null and self.output_path != null) {
            return FlagEval.file_out;
        }

        // passed Code Directly
        if (self.code_str != null) {
            return FlagEval.inline_code;
        }

        return FlagEval.invalid;
    }

    pub fn evaluateFlags(self: Flags) u8 {

        // passed no file or direct code
        if (self.file_path == null and self.code_str == null) {
            return 0;
        }

        // passed file but no output
        if (self.file_path != null and self.output_path == null) {
            return 1;
        }

        // passed file and output path
        if (self.file_path != null and self.output_path != null) {
            return 2;
        }

        // passed Code Directly
        if (self.code_str != null) {
            return 3;
        }

        return 0;
    }

    pub fn checkFileFlags(self: Flags) void {
        if (self.file_path == null) {
            print("Use -f to point to a File to convert to a Fragment.\n", .{});
        }
    }

    pub fn format(
        self: Flags,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("Flags:\n", .{});
        if (self.file_path) |fp| try writer.print("  File Path: {s}\n", .{fp});
        if (self.output_path) |op| try writer.print("  Output Path: {s}\n", .{op});
        if (self.lang) |lg| try writer.print("  Language: {s}\n", .{lg});
        try writer.print("  Print: {}\n", .{self.print});
        try writer.print("  Help: {}\n", .{self.help});
        if (self.title) |t| try writer.print("  Title: {s}\n", .{t});
        if (self.description) |d| try writer.print("  Description: {s}\n", .{d});
        if (self.prefix) |p| try writer.print("  Prefix: {s}\n", .{p});
        if (self.confirmation == true) try writer.print("  Confirmation: true\n", .{});
        if (self.code_str) |cs|
            for (cs) |line| try writer.print("  Code String: {c}\n", .{line});
    }

    pub fn printHelp(self: Flags) !void {
        _ = self;

        const out = std.io.getStdOut();
        var buf = std.io.bufferedWriter(out.writer());
        const w = buf.writer();

        try w.print("{s}", .{constants.HELP_MSG});

        try buf.flush();
    }
};
