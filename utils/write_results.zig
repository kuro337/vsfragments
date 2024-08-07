const std = @import("std");

const Snippet = @import("snippet").Snippet;
const constants = @import("constants");

pub fn inlineBufferedIO(snippet: Snippet) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    try w.print("{s}", .{constants.stdout_init_msg});

    // Print the section limiter and usage notes
    try w.print("\n{s}\n\n", .{constants.usage_notes});

    // Print Usage for Fragment (color)
    try w.print("{s}\n", .{constants.snippet_optional_args_usage});

    try w.print("{s}\n\n{s}\n", .{ constants.large_star_delimiter, constants.usages_bold });

    try w.print("{s}\n", .{constants.STANDARD_USAGE_EXAMPLES});

    // Successfully Generated Fragment from Inline Input....

    try w.print("\n{s}{s}\n{s}\n{s}{s}\n\n", .{
        constants.stdout_section_limiter,
        constants.stdout_section_limiter,
        constants.successfully_created_inline_msg,
        constants.stdout_section_limiter,
        constants.stdout_section_limiter,
    });

    // Print Generated Fragment

    try w.print("{s}\n", .{snippet});

    try w.print("{s}{s}\n{s}\n\n{s}\n", .{ constants.stdout_section_limiter, constants.stdout_section_limiter, constants.success_fragment_usage, constants.inline_success_fragment_usage });
    try buf.flush();
}

pub fn writeBufferedIO(snippet: Snippet) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());

    // Get the Writer interface from BufferedWriter
    var w = buf.writer();

    try w.print("{s}", .{constants.FILEIO_AFTER_CMD_MSG});

    try w.print("{s}\n", .{snippet});

    try w.print("{s}{s}\n\n", .{ constants.stdout_section_limiter, constants.stdout_section_limiter });

    try buf.flush();
}

// Formats an Array by a Prefix,Suffix, and Seperator and returns the String
// @Usage:
//    const result = try formatString(allocator, &lines, "\"", "\"", ",");
//    defer allocator.free(result);
pub fn formatString(allocator: std.mem.Allocator, lines: [][]const u8, prefix: []const u8, suffix: []const u8, sep: []const u8) ![]u8 {
    const n = lines.len;

    if (n == 0) {
        // Handle empty case
        return try std.fmt.allocPrint(allocator, "[]", .{});
    }
    var writer = std.ArrayList(u8).init(allocator);
    defer writer.deinit();
    try writer.writer().print("[{s}{s}{s}{s} ", .{ prefix, lines[0], suffix, sep });
    for (lines[1 .. n - 1]) |line| {
        try writer.writer().print("{s}{s}{s}{s} ", .{ prefix, line, suffix, sep });
    }

    try writer.writer().print("{s}{s}{s}]", .{ prefix, lines[n - 1], suffix });

    return writer.toOwnedSlice();
}
