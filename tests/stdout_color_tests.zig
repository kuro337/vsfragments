const std = @import("std");

test "Multiline ANSI Behavior" {
    const lit_str = "\x1b[96mThis text will be Sky blue\x1b[0m";
    std.debug.print("\nString Literal:\n{s}\n\n", .{lit_str});

    const l = "r";
    _ = l; // autofix

    const multi_str =
        \\
        \\   \x1b[96mThis text will be Sky blue\x1b[0m
        \\
    ;

    std.debug.print("Multiline String:\n{s}\n", .{multi_str});
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

    try std.testing.expect(true);
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

test "Application Relevant Colors" {
    const bold_green = "\x1b[1;32mThis text will be bold green\x1b[0m";
    const red_err_text = "\x1b[31mThis text will be red error text.\x1b[0m";
    const red_bold_err_text = "\x1b[1mThis text will be bold error text.\x1b[0m";
    const warning_yellow = "\x1b[33mNot Recommended for Production\x1b[0m";
    const warning_bright_yellow = "\x1b[93mWWarning: Make sure no Memory Leaks Present.\x1b[0m";
    const warning_bold_yellow = "\x1b[1;33mWARNING: Check Memory Usage..\x1b[0m";
    const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";
    const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";
    const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
    const italic_text = "\x1b[3mThis text will be italic\x1b[0m"; // May not work in all terminals
    const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";

    std.debug.print("{s}\n", .{bold_green});
    std.debug.print("{s}\n", .{red_err_text});
    std.debug.print("{s}\n", .{red_bold_err_text});
    std.debug.print("{s}\n", .{warning_yellow});
    std.debug.print("{s}\n", .{warning_bright_yellow});
    std.debug.print("{s}\n", .{warning_bold_yellow});
    std.debug.print("{s}\n", .{light_grey});
    std.debug.print("{s}\n", .{bright_white});
    std.debug.print("{s}\n", .{bold_text});
    std.debug.print("{s}\n", .{italic_text});
    std.debug.print("{s}\n", .{underline_text});
}
test "Whitish Colors" {

    // darker  grey   \x1b[90m   \x1b[0m
    // lighter grey   \x1b[37m   \x1b[0m
    // bright  white  \x1b[97m   \x1b[0m

    const dark_grey = "\x1b[90mThis text will be dark grey\x1b[0m";
    const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";
    const bright_black = "\x1b[90mThis text will be bright black (dark gray)\x1b[0m";
    const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";

    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    try w.print("\n{s}", .{dark_grey});
    try w.print("\n{s}", .{light_grey});
    try w.print("\n{s}", .{bright_white});
    try w.print("\n{s}", .{bright_black});

    try w.print("\nWhitishh Strings ANSI Escaped Printed", .{});

    try buf.flush();

    try std.testing.expect(true);
}

test "Print Colors" {
    const sky_blue = "\x1b[96mThis text will be Sky blue\x1b[0m";
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
    const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
    const italic_text = "\x1b[3mThis text will be italic\x1b[0m"; // May not work in all terminals
    const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";
    const blinking_text = "\x1b[5mThis text will blink\x1b[0m"; // Use sparingly
    const inverted_colors_text = "\x1b[7mThis text will have inverted colors\x1b[0m";
    const red_err_text = "\x1b[31mThis text will be red error text.\x1b[0m";
    const red_bold_err_text = "\x1b[1mThis text will be bold error text.\x1b[0m";
    const warning_yellow = "\x1b[33mNot Recommended for Production\x1b[0m";
    const warning_bright_yellow = "\x1b[93mWWarning: Make sure no Memory Leaks Present.\x1b[0m";
    const warning_bold_yellow = "\x1b[1;33mWARNING: Check Memory Usage..\x1b[0m";
    const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";

    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    // Test Section

    try w.print("\n{s}", .{bright_green});
    try w.print("\n{s}", .{standard_green});
    try w.print("\n{s}", .{dark_green});
    try w.print("\n{s}", .{bold_green});
    try w.print("\n{s}", .{bright_white});
    try w.print("\n{s}", .{sky_blue});
    try w.print("\n{s}", .{bright_blue});
    try w.print("\n{s}", .{bright_red});
    try w.print("\n{s}", .{bright_yellow});
    try w.print("\n{s}", .{bright_cyan});
    try w.print("\n{s}", .{bright_magenta});
    try w.print("\n{s}", .{bright_black});
    try w.print("\n{s}", .{bold_text});
    try w.print("\n{s}", .{italic_text});
    try w.print("\n{s}", .{underline_text});
    try w.print("\n{s}", .{blinking_text});
    try w.print("\n{s}", .{inverted_colors_text});
    try w.print("\nColored Strings ANSI Escaped Printed", .{});

    std.debug.print("{s}\n", .{red_err_text});
    std.debug.print("{s}\n", .{red_bold_err_text});
    std.debug.print("{s}\n", .{warning_yellow});
    std.debug.print("{s}\n", .{warning_bright_yellow});
    std.debug.print("{s}\n", .{warning_bold_yellow});
    std.debug.print("{s}\n", .{light_grey});
    std.debug.print("{s}\n", .{bold_text});
    std.debug.print("{s}\n", .{italic_text});
    std.debug.print("{s}\n", .{underline_text});
    try buf.flush();

    try std.testing.expect(true);
}
