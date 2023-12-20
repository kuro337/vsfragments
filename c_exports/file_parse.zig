const std = @import("std");

// Export this Function - it should accept a C string and return the Snippet String

export fn parseFileGetSnippet(file_path: [*c]const u8) [*c]const u8 {
    const zig_file_path = std.mem.span(file_path);

    // try parseFileAndPrint(allocator, file_path) (update it to return snippet instead of just printing)

    return zig_file_path;
}
// test to see how null input handled

//  parseFileGetSnippet(filePath: string): string;

// zig build-exe vector.zig
// ./vector
// zig test file.zig
