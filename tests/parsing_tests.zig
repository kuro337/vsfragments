const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const readLinesFromFile = @import("read_lines").readLinesFromFile;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

test "Test Reading File and Transforming to Snippet" {
    var expected_transformed_lines = [_][]const u8{
        "# Threading OS Threads",
        "",
        "```rust",
        "const std = @import(\"std\");",
        "const expect = std.testing.expect;",
        "const print = std.debug.print;",
        "const ArrayList = std.ArrayList;",
        "const test_allocator = std.testing.allocator;",
        "const eql = std.mem.eql;",
        "const Thread = std.Thread;",
        "",
        "pub fn main() !void {",
        "\tstd.debug.print(\"{s}\\n\", .{\"Hello, world!\"});",
        "}",
        "```",
    };

    // Create the expected Snippet instance
    const expectedSnippet = Snippet{
        .title = "\"Go HTTP Server Snippet\": {",
        .prefix = "\"prefix\": \"gohttpserver\",",
        .body = &expected_transformed_lines,
        .description = "\"description\": \"Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.\"",
        .create_flag = false,
    };

    const allocator = std.testing.allocator;

    const linesArrayList = try readLinesFromFile(allocator, "tests/testfile.txt");
    defer clearSliceMatrixMemory(linesArrayList, std.testing.allocator);

    const transformedSnippet = try Snippet.createFromLines(allocator, linesArrayList, false);
    defer clearSliceMatrixMemory(transformedSnippet.body, allocator);

    try std.testing.expectEqualStrings(expectedSnippet.title, transformedSnippet.title);
    try std.testing.expectEqualStrings(expectedSnippet.prefix, transformedSnippet.prefix);
    try std.testing.expectEqualStrings(expectedSnippet.description, transformedSnippet.description);

    try std.testing.expectEqual(expectedSnippet.body.len, transformedSnippet.body.len);
    try std.testing.expect(transformedSnippet.body.len > 0);
}

test "Parse ANSI Coded Characters" {
    const ansi_escaped_ml =
        \\ const bold_green = "\x1b[1;32mThis text will be bold green\x1b[0m";
        \\ const red_err_text = "\x1b[31mThis text will be red error text.\x1b[0m";
        \\ const red_bold_err_text = "\x1b[1mThis text will be bold error text.\x1b[0m";
        \\ const warning_yellow = "\x1b[33mNot Recommended for Production\x1b[0m";
        \\ const warning_bright_yellow ="\x1b[93mWWarning: Make sure no Memory Leaks Present.\x1b[0m";
        \\ const warning_bold_yellow = "\x1b[1;33mWARNING: Check Memory Usage..\x1b[0m";
        \\ const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";
        \\ const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";
        \\ const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
        \\ const italic_text = "\x1b[3mThis text will be italic\x1b[0m"; // May not work in all terminals
        \\ const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";
    ;

    var splitLines = std.ArrayList([]const u8).init(std.testing.allocator);
    defer splitLines.deinit();

    var split = std.mem.splitScalar(u8, ansi_escaped_ml, '\n');

    while (split.next()) |line| {
        try splitLines.append(line);
    }

    const split_ansi = try splitLines.toOwnedSlice();
    defer std.testing.allocator.free(split_ansi);

    var og_parser = std.ArrayList([]const u8).init(std.testing.allocator);

    defer {
        for (og_parser.items) |item| {
            std.testing.allocator.free(item);
        }
        og_parser.deinit();
    }

    for (split_ansi) |c| {
        const serialized_line = try Snippet.parseLine(std.testing.allocator, c);
        try og_parser.append(serialized_line);
    }

    const arr = &[_][]const u8{
        " const bold_green = \"\\x1b[1;32mThis text will be bold green\\x1b[0m\";",
        " const red_err_text = \"\\x1b[31mThis text will be red error text.\\x1b[0m\";",
        " const red_bold_err_text = \"\\x1b[1mThis text will be bold error text.\\x1b[0m\";",
        " const warning_yellow = \"\\x1b[33mNot Recommended for Production\\x1b[0m\";",
        " const warning_bright_yellow =\"\\x1b[93mWWarning: Make sure no Memory Leaks Present.\\x1b[0m\";",
        " const warning_bold_yellow = \"\\x1b[1;33mWARNING: Check Memory Usage..\\x1b[0m\";",
        " const light_grey = \"\\x1b[37mThis text will be light grey\\x1b[0m\";",
        " const bright_white = \"\\x1b[97mThis text will be bright white\\x1b[0m\";",
        " const bold_text = \"\\x1b[1mThis text will be bold\\x1b[0m\";",
        " const italic_text = \"\\x1b[3mThis text will be italic\\x1b[0m\"; // May not work in all terminals",
        " const underline_text = \"\\x1b[4mThis text will be underlined\\x1b[0m\";",
    };
    _ = arr;

    for (og_parser.items) |p| {
        _ = p; // autofix

        // std.debug.print("{s}\n", .{p}); // converted lines shud be equal to above lines
    }
}
