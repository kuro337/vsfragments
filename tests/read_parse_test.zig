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
        .title = "\"Zig Snippet\": {",
        .prefix = "\"prefix\": \"testparse\",",
        .description = "\"description\": \"Log output to console\"",
        .body = &expected_transformed_lines,
    };

    const allocator = std.testing.allocator;

    const linesArrayList = try readLinesFromFile(&std.testing.allocator, "tests/testfile.txt");
    defer clearSliceMatrixMemory(linesArrayList, &allocator);

    const transformedSnippet = try Snippet.fromLinesAutoMemory(&allocator, linesArrayList);
    defer clearSliceMatrixMemory(transformedSnippet.body, &allocator);

    print("Snippet:\n{}\n", .{transformedSnippet});

    try std.testing.expectEqualStrings(expectedSnippet.title, transformedSnippet.title);
    try std.testing.expectEqualStrings(expectedSnippet.prefix, transformedSnippet.prefix);
    try std.testing.expectEqualStrings(expectedSnippet.description, transformedSnippet.description);

    try std.testing.expectEqual(expectedSnippet.body.len, transformedSnippet.body.len);
    try std.testing.expect(transformedSnippet.body.len > 0);
}
