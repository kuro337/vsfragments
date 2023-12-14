const std = @import("std");
const print = std.debug.print;
const checkMemoryLeaks = @import("utils/memory_mgmt.zig").checkMemoryLeaks;

pub fn main() !void {
    std.debug.print("{s}\n", .{"Find Pos to Insert Snippet"});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer checkMemoryLeaks(&gpa);

    const file_path = "/Users/kuro/Documents/Code/Zig/FileIO/parser/mock/empty.code-snippets";
    const position = try findPositionToInsert(&allocator, file_path);

    std.debug.print("Position of second last '}}': {}\n", .{position});
}

pub fn findPositionToInsert(allocator: *const std.mem.Allocator, file_path: []const u8) !usize {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    // Determine the file size
    const fileSize = try file.getEndPos();

    // Handle empty file
    if (fileSize == 0) return 0;

    // Allocate a buffer to hold the file content
    const buffer = try allocator.alloc(u8, fileSize);
    defer allocator.free(buffer);

    // Read the file content into the buffer
    _ = try file.readAll(buffer);
    const snippet_insertion_pos = findSecondLastBracePosition(buffer);

    try readFilefindPositionToInsert(buffer, snippet_insertion_pos, fileSize);

    return snippet_insertion_pos;
}

fn findSecondLastBracePosition(buffer: []const u8) usize {
    var braceCount: usize = 0;
    var isInComment = false;

    var index = buffer.len - 1;
    while (index > 0) {
        const char = buffer[index];

        // Skip the current line if it's a comment.
        if (isInComment) {
            if (char == '\n') {
                isInComment = false;
            }
            index -= 1;
            continue;
        }

        // Check for start of a single line comment.
        if (index > 0 and buffer[index - 1] == '/' and char == '/') {
            isInComment = true;
            index -= 2; // Skip the "//"
            continue;
        }

        // Count closing braces.
        if (char == '}') {
            braceCount += 1;
            if (braceCount == 2) {
                return index;
            }
        }

        index -= 1;
    }

    // Return 0 if less than two closing braces found.
    return 0;
}

pub fn readFilefindPositionToInsert(buffer: []const u8, read_start_pos: usize, file_end_pos: usize) !void {

    // Print the file content from the position to the end of the file
    if (read_start_pos < file_end_pos) {
        print("Remaining File content from position {}:\n{s}\n", .{ read_start_pos, buffer[read_start_pos..] });
    } else {
        print("Position is at or beyond the end of the file.\n", .{});
    }
}

test "Read File and Find Pos of Insertion Position" {
    var allocator = std.testing.allocator;

    const file_path = "/Users/kuro/Documents/Code/Zig/FileIO/parser/mock/empty.code-snippets";
    const position = try findPositionToInsert(&allocator, file_path);

    if (position == 0) {
        print("File is empty, has only comments, or has less than 2 closing braces\n", .{});
    }
    try readFilefindPositionToInsert(&allocator, position, file_path);

    std.debug.print("Position of second last '}}': {}\n", .{position});
}
