const std = @import("std");

const Snippet = @import("snippet").Snippet;
const constants = @import("constants");

pub fn printInlineFragmentBuffered(snippet: Snippet) !void {
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

pub fn printFragmentBufferedFileIO(snippet: Snippet) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());

    // Get the Writer interface from BufferedWriter
    var w = buf.writer();

    try w.print("{s}", .{constants.FILEIO_AFTER_CMD_MSG});

    try w.print("{s}\n", .{snippet});

    try w.print("{s}{s}\n\n", .{ constants.stdout_section_limiter, constants.stdout_section_limiter });

    try buf.flush();
}
