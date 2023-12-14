const std = @import("std");
const print = std.debug.print;

const transformFileToSnippet = @import("json_parser.zig").transformFileToSnippet;

const checkMemoryLeaks = @import("utils/memory_mgmt.zig").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("utils/memory_mgmt.zig").clearSliceMatrixMemory;

pub fn main() !void {
    print("{s}\n", .{"Running Vector Snippet Parser"});

    // 0. Create Allocator for Application

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer checkMemoryLeaks(&gpa);

    // 1. Read File -> Return Snippet

    const transformed_snippet = try transformFileToSnippet(&allocator, "testfile.txt");
    defer clearSliceMatrixMemory(transformed_snippet.body, &allocator);

    // 2. Print Snippet
    print("Final Snippet -> Add to Snippets File.{}\n", .{transformed_snippet});
}
