# zls

- Setting up the language server is very straightforward , these are the only commands required.

<br/>

```bash
# clone and build

git clone git@github.com:zigtools/zls.git && cd zls
zig build -Doptimize=ReleaseSafe

# validate 

cd zls/zig-out/bin && chmod +x zls

# confirm the lang server runs

./zls

# Optionally Add Binary to Path  

sudo cp zls/zig-out/bin/zls  /usr/local/zig/bin/

```

<br/>

VSCode Extension Settings for Language Server

<br/>

- Install the Official *Zig Language Server* Extension

<br/>

- Update *settings.json* to point to the binary

<br/>

```json
{
  "zig.path": "/usr/local/zig/bin/zig",
  "zig.initialSetupDone": true,
  "zig.zls.zigLibPath": "/usr/local/zig/lib/zig/",
  "zig.zls.semanticTokens": "full",
  "zig.formattingProvider": "zls",
  "zig.zls.path": "/usr/local/zig/bin/zls",
  "zig.zls.warnStyle": true,
}
```

<br/>

- That should be it! 

<br/>


## validate

<br/>


- Open a File 

- Create *hello.zig*

<br/>

```rust
const std = @import("std");

test "Print Colors" {
    const blue_background = "\x1b[44m                  \x1b[0m";
    const delimiter = "\x1b[2;37m======================================================\x1b[0m";
    const cmd_usage = "\x1b[1;94mvsfragment\x1b[0m -f hello.zig";
    const sky_blue = "\x1b[96mThis text will be Sky blue\x1b[0m";
    const bright_blue = "\x1b[94mThis text will be bright blue\x1b[0m";
    const bright_red = "\x1b[91mThis text will be bright red\x1b[0m";
    const bright_green = "\x1b[92mThis text will be bright green\x1b[0m";
    const bright_yellow = "\x1b[93mThis text will be bright yellow\x1b[0m";
    const bright_cyan = "\x1b[96mThis text will be bright cyan\x1b[0m";
    const vs_step_one = "cmd + shift + p\x1b[0m -> Snippets: Configure Code Snippets";
    const vs_step_two = "\x1b[97m- Paste cmd output and set the prefix as zig_color_test";
    const vs_step_three = "Control ^ + Space\x1b[0m + zig_color_test\x1b[0m";
    const inverted_colors_text = "\x1b[7mEasy! Now try using vsfragment! :) \x1b[0m";
    const bright_magenta = "\x1b[95mThis text will be bright magenta\x1b[0m";
    const bright_black = "\x1b[90mThis text will be bright black (dark gray)\x1b[0m";
    const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";
    const standard_green = "\x1b[32mThis text will be standard green\x1b[0m";
    const dark_green = "\x1b[2;32mThis text will be dark green\x1b[0m";
    const bold_green = "\x1b[1;32mThis text will be bold green\x1b[0m";
    const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
    const italic_text = "\x1b[3mThis text will be italic\x1b[0m";
    const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";
    const red_err_text = "\x1b[31mThis text will be red error text.\x1b[0m";
    const red_bold_err_text = "\x1b[1mThis text will be bold error text.\x1b[0m";
    const warning_yellow = "\x1b[33mNot Recommended for Production\x1b[0m";
    const warning_bright_yellow = "\x1b[93mWWarning Message Present.\x1b[0m";
    const warning_bold_yellow = "\x1b[1;33mWARNING: Check Memory Usage..\x1b[0m";
    const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";
    const alt_cmd_info = "- Optionally use the --prefiix flag to include a prefix";
    const alt_cmd_usage = "vsfragment\x1b[0m -f hello.zig --prefix 'zig_color_test'";

  
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    try w.print("\n{s}", .{inverted_colors_text});
    try w.print("\n{s}\n", .{delimiter});
    try w.print("\n{s}\n\n", .{blue_background});
    try w.print("\n{s}\n\n", .{cmd_usage});
    try w.print("\n\x1b[97m- \x1b[1;33m{s}\x1b[0m\n\n", .{vs_step_one});
    try w.print("{s}\x1b[0m\n\n", .{vs_step_two});
    try w.print("\x1b[97m- \x1b[1;33m{s}\n\n\n", .{vs_step_three});
    try w.print("{s}", .{alt_cmd_info});
    try w.print("\n\n\x1b[1;94m{s}\n", .{alt_cmd_usage});
    try w.print("\n{s}\n", .{delimiter});
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
    try w.print("\n{s}\n", .{red_err_text});
    try w.print("{s}\n", .{red_bold_err_text});
    try w.print("{s}\n", .{warning_yellow});
    try w.print("{s}\n", .{warning_bright_yellow});
    try w.print("{s}\n", .{warning_bold_yellow});
    try w.print("{s}\n", .{light_grey});
    try w.print("{s}\n", .{bold_text});
    try w.print("{s}\n", .{italic_text});
    try w.print("{s}\n", .{underline_text});
    try w.print("\nColored Strings ANSI Escaped Printed", .{});

    try buf.flush();

    try std.testing.expect(true);
}

```

<br/>

run the test , simple design
  


```bash

zig test hello.zig

```