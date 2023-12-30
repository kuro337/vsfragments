const std = @import("std");
const print = std.debug.print;

//PARSED SHOULD EVALUATE TO THIS
test "Color Codes Valid" {
    const bold_green = "\x1b[1;32mPARSE_TEST text will be bold green\x1b[0m";
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
