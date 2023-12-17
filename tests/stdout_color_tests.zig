const std = @import("std");

pub fn main() !void {
    std.debug.print("{s}\n", .{"Hello, world!"});
}

test "Allocated stdout Printer" {
    const stdout_start_star_limiter = "\x1b[90m***********************\x1b[0m";
    const stdout_init_msg = "\n\x1b[92mCreating Fragment\x1b[0m\n";

    // Use format to create the combined string
    const formatted_message = try std.fmt.allocPrint(std.testing.allocator, "{s}{s}{s}", .{ stdout_start_star_limiter, stdout_init_msg, stdout_start_star_limiter });
    defer std.testing.allocator.free(formatted_message);

    // Print the formatted message
    const out = std.io.getStdOut().writer();
    try out.writeAll(formatted_message);
}

test "ANSI Special Escapes" {
    const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
    const italic_text = "\x1b[3mThis text will be italic\x1b[0m"; // May not work in all terminals
    const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";
    const blinking_text = "\x1b[5mThis text will blink\x1b[0m"; // Use sparingly
    const inverted_colors_text = "\x1b[7mThis text will have inverted colors\x1b[0m";

    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    // Test Section
    try w.print("\n{s}", .{bold_text});
    try w.print("\n{s}", .{italic_text});
    try w.print("\n{s}", .{underline_text});
    try w.print("\n{s}", .{blinking_text});
    try w.print("\n{s}", .{inverted_colors_text});

    try w.print("\nSpecial Strings ANSI Escaped Printed", .{});

    try buf.flush();

    try std.testing.expect(true);
}

test "Print Colors" {
    const bright_blue = "\x1b[94mThis text will be bright blue\x1b[0m";
    const bright_red = "\x1b[91mThis text will be bright red\x1b[0m";
    const bright_green = "\x1b[92mThis text will be bright green\x1b[0m";
    const bright_yellow = "\x1b[93mThis text will be bright yellow\x1b[0m";
    const bright_cyan = "\x1b[96mThis text will be bright cyan\x1b[0m";
    const bright_magenta = "\x1b[95mThis text will be bright magenta\x1b[0m";
    const bright_black = "\x1b[90mThis text will be bright black (dark gray)\x1b[0m";
    const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";
    const standard_green = "\x1b[32mThis text will be standard green\x1b[0m";
    const dark_green = "\x1b[2;32mThis text will be dark green\x1b[0m";
    const bold_green = "\x1b[1;32mThis text will be bold green\x1b[0m";
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    // Get the Writer interface from BufferedWriter
    var w = buf.writer();

    // Test Section

    try w.print("\n{s}", .{bright_green});
    try w.print("\n{s}", .{standard_green});
    try w.print("\n{s}", .{dark_green});
    try w.print("\n{s}", .{bold_green});
    try w.print("\n{s}", .{bright_white});
    try w.print("\n{s}", .{bright_blue});
    try w.print("\n{s}", .{bright_red});
    try w.print("\n{s}", .{bright_yellow});
    try w.print("\n{s}", .{bright_cyan});
    try w.print("\n{s}", .{bright_magenta});
    try w.print("\n{s}", .{bright_black});

    try w.print("\nColored Strings ANSI Escaped Printed", .{});

    try buf.flush();

    try std.testing.expect(true);
}
// zig build-exe stdout_color_tests.zig
// ./vector
// zig test stdout_color_tests.zig
