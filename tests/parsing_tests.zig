const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const readLinesFromFile = @import("read_lines").readLinesFromFile;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

// PARSED SHOULD EVALUATE TO THIS
// test "Color Codes Valid" {
//     const bold_green = "\x1b[1;32mPARSE_TEST text will be bold green\x1b[0m";
//     const red_err_text = "\x1b[31mThis text will be red error text.\x1b[0m";
//     const red_bold_err_text = "\x1b[1mThis text will be bold error text.\x1b[0m";
//     const warning_yellow = "\x1b[33mNot Recommended for Production\x1b[0m";
//     const warning_bright_yellow = "\x1b[93mWWarning: Make sure no Memory Leaks Present.\x1b[0m";
//     const warning_bold_yellow = "\x1b[1;33mWARNING: Check Memory Usage..\x1b[0m";
//     const light_grey = "\x1b[37mThis text will be light grey\x1b[0m";
//     const bright_white = "\x1b[97mThis text will be bright white\x1b[0m";
//     const bold_text = "\x1b[1mThis text will be bold\x1b[0m";
//     const italic_text = "\x1b[3mThis text will be italic\x1b[0m"; // May not work in all terminals
//     const underline_text = "\x1b[4mThis text will be underlined\x1b[0m";

//     std.debug.print("{s}\n", .{bold_green});
//     std.debug.print("{s}\n", .{red_err_text});
//     std.debug.print("{s}\n", .{red_bold_err_text});
//     std.debug.print("{s}\n", .{warning_yellow});
//     std.debug.print("{s}\n", .{warning_bright_yellow});
//     std.debug.print("{s}\n", .{warning_bold_yellow});
//     std.debug.print("{s}\n", .{light_grey});
//     std.debug.print("{s}\n", .{bright_white});
//     std.debug.print("{s}\n", .{bold_text});
//     std.debug.print("{s}\n", .{italic_text});
//     std.debug.print("{s}\n", .{underline_text});
// }

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
        .title = "Go HTTP2 Server Snippet",
        .prefix = "gohttpserver",
        .body = &expected_transformed_lines,
        .description = "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.",
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
    const ANSI_INPUT_DATA_FILE = "tests/MOCK_PARSER_DATA/ansi/input.txt";
    const split_ansi = try readLinesFromFile(std.testing.allocator, ANSI_INPUT_DATA_FILE);

    const EXPECTED_OUTPUT_DATA_FILE = "tests/MOCK_PARSER_DATA/ansi/expected_output.txt";
    const expected_output = try readLinesFromFile(std.testing.allocator, EXPECTED_OUTPUT_DATA_FILE);

    defer {
        for (split_ansi) |line| {
            std.testing.allocator.free(line);
        }
        std.testing.allocator.free(split_ansi);

        for (expected_output) |line| {
            std.testing.allocator.free(line);
        }

        std.testing.allocator.free(expected_output);
    }

    for (split_ansi, 0..) |c, i| {
        const serialized_line = try Snippet.parseLine(std.testing.allocator, c);

        defer std.testing.allocator.free(serialized_line);

        try std.testing.expectEqualStrings(serialized_line, expected_output[i]);
    }

    try std.testing.expect(true);
}

// BACKSLASH ISSUES \n ISSUES

// Input  -> Desired Parse

//  \n    ->  \\n
//  $     ->  \\$
//  \\n   ->  \\\\\\n   [ \ -> \\ , \n -> \\n - but then side by side it evalutes into \n instead of \\n ]
//  \\nn  -> \\\\\\nn

test "JS console.log with Newline Parsing Tests" {
    const INPUT_FILE_PATH_JS_BACKTICKS = "tests/MOCK_PARSER_DATA/js/input_backticks.txt";
    const input_data = try readLinesFromFile(std.testing.allocator, INPUT_FILE_PATH_JS_BACKTICKS);

    const EXPECTED_OUTPUT_DATA_FILE = "tests/MOCK_PARSER_DATA/js/output_expected.txt";

    const expected_output = try readLinesFromFile(std.testing.allocator, EXPECTED_OUTPUT_DATA_FILE);

    defer {
        for (input_data) |line| {
            std.testing.allocator.free(line);
        }
        std.testing.allocator.free(input_data);

        for (expected_output) |line| {
            std.testing.allocator.free(line);
        }

        std.testing.allocator.free(expected_output);
    }

    for (input_data, 0..) |c, i| {
        const serialized_line = try Snippet.parseLine(std.testing.allocator, c);

        defer std.testing.allocator.free(serialized_line);

        try std.testing.expectEqualStrings(serialized_line, expected_output[i]);
    }

    try std.testing.expect(true);
}
