const std = @import("std");

const Snippet = @import("snippet").Snippet;

pub fn printFragmentBuffered(snippet: Snippet) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    const stdout_section_limiter = @import("constants").stdout_section_limiter;
    const snippet_optional_args_usage = @import("constants").snippet_optional_args_usage;
    const usage_notes = @import("constants").usage_notes;
    const usages_bold = @import("constants").usages_bold;

    // Success
    const success_fragment_usage = @import("constants").success_fragment_usage;
    const successfully_created_inline_msg = @import("constants").successfully_created_inline_msg;

    // examples
    const binary_custom_usage_cmd = @import("constants").binary_custom_usage_cmd;
    const binary_custom_usage = @import("constants").binary_custom_usage;
    const binary_f_o_usage = @import("constants").binary_f_o_usage;
    const fragment_input_output_usage = @import("constants").fragment_input_output_usage;

    // Print the section limiter and usage notes
    try w.print("\n{s}\n\n{s}\n", .{ stdout_section_limiter, usage_notes });

    // Print Usage for Fragment (color)
    try w.print("{s}\n", .{snippet_optional_args_usage});

    try w.print("{s}\n", .{usages_bold});

    // // Print Examples
    try w.print("\n{s}\n{s}\n", .{ binary_custom_usage, binary_custom_usage_cmd });
    try w.print("\n{s}\n\n{s}\n", .{ binary_f_o_usage, fragment_input_output_usage });

    // Successfully Generated Fragment from Inline Input....

    try w.print("\n{s}{s}\n{s}\n{s}{s}\n", .{
        stdout_section_limiter,
        stdout_section_limiter,
        successfully_created_inline_msg,
        stdout_section_limiter,
        stdout_section_limiter,
    });

    // Print Generated Fragment

    try w.print("{s}\n", .{snippet});

    try w.print("{s}{s}\n{s}\n", .{ stdout_section_limiter, stdout_section_limiter, success_fragment_usage });
    try buf.flush();
}

pub fn printFragmentBufferedFileIO(snippet: Snippet) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());

    const stdout_section_limiter = @import("constants").stdout_section_limiter;
    const stdout_result_limiter = @import("constants").stdout_result_limiter;
    _ = stdout_result_limiter;

    // Success
    const successfully_created_fileio_msg = @import("constants").successfully_created_fileio_msg;

    // Get the Writer interface from BufferedWriter
    var w = buf.writer();

    try w.print("\n{s}{s}\n{s}\n{s}{s}\n", .{
        stdout_section_limiter,
        stdout_section_limiter,
        successfully_created_fileio_msg,
        stdout_section_limiter,
        stdout_section_limiter,
    });

    try w.print("{s}\n", .{snippet});

    try w.print("{s}{s}\n\n", .{ stdout_section_limiter, stdout_section_limiter });
    try buf.flush();
}
