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
    file_path: []const u8 = "",
    output_path: []const u8 = "",
    code_str: []const u8 = "",
    lang: []const u8 = "",
    help: bool = false,
    print: bool = false,
    title: []const u8 = "",
    description: []const u8 = "",
    prefix: []const u8 = "",
    confirmation: bool = false,
    force: bool = false,

    pub fn evalCmds(self: Flags) FlagEval {

        // passed no file or direct code

        if (std.mem.eql(u8, self.file_path, "") and
            std.mem.eql(u8, self.code_str, ""))
        {
            //            std.debug.print("no -f or -c passed , invalid", .{});
            return FlagEval.invalid;
        }

        // passed file but no output

        if (!std.mem.eql(u8, self.file_path, "") and
            std.mem.eql(u8, self.output_path, ""))
        {
            //    std.debug.print("-f passed no -o  , file", .{});

            return FlagEval.file;
        }

        // passed file and output path

        if (!std.mem.eql(u8, self.file_path, "") and
            !std.mem.eql(u8, self.output_path, ""))
        {
            //    std.debug.print("-f and -o passed , file_out", .{});

            return FlagEval.file_out;
        }

        // passed inline only

        if (!std.mem.eql(u8, self.code_str, "")) {
            //            std.debug.print("-c passed, inline", .{});

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
        if (self.file_path.len > 1) try writer.print("  File Path: {s}\n", .{self.file_path});
        if (self.output_path.len > 1) try writer.print("  Output Path: {s}\n", .{self.output_path});
        if (self.lang.len > 1) try writer.print("  Language: {s}\n", .{self.lang});
        try writer.print("  Print: {}\n", .{self.print});
        try writer.print("  Help: {}\n", .{self.help});
        if (self.title.len > 1) try writer.print("  Title: {s}\n", .{self.title});
        if (self.description.len > 1) try writer.print("  Description: {s}\n", .{self.description});
        if (self.prefix.len > 1) try writer.print("  Prefix: {s}\n", .{self.prefix});
        if (self.confirmation == true) try writer.print("  Confirmation: true\n", .{});
        if (self.code_str.len > 1) try writer.print("  Code String: {c}\n", .{self.code_str});
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
