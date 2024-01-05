const std = @import("std");
const print = std.debug.print;

const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const Snippet = @import("snippet").Snippet;

pub fn checkFileExists(file_path: []const u8) !bool {
    if (std.fs.cwd().openFile(file_path, .{})) |file| {
        defer file.close();
        return true;
    } else |err| switch (err) {
        error.FileNotFound => {
            return false;
        },
        else => |leftover_err| return leftover_err,
    }
}

pub fn findPositionToInsert(allocator: std.mem.Allocator, file_path: []const u8) !usize {
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

test "Populated File - Read File and Find Pos of Insertion Position" {
    var allocator = std.testing.allocator;

    const file_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/mock/populated.code-snippets";
    const position = try findPositionToInsert(&allocator, file_path);

    std.debug.print("Position of second last '}}': {}\n", .{position});
}

pub fn writeSnippetToFileAtByteOffset(allocator: std.mem.Allocator, snippet: Snippet, file_path: []const u8, position: usize) !void {
    _ = allocator;
    // Open the file
    const file = try std.fs.openFileAbsolute(file_path, .{ .mode = .read_write });
    defer file.close();

    if (position == 0) {
        try file.writeAll("{\n");
    } else {
        // Seek to the desired position
        try file.seekTo(position + 1);
        _ = try file.write(",\n"); // for now manually add the last newline + }

    }

    // Write the snippet to the file
    // Define an empty FormatOptions struct
    const formatOptions = std.fmt.FormatOptions{};

    // Write the snippet to the file
    try snippet.format("", formatOptions, file.writer());

    _ = try file.write("}"); // for now manually add the last newline + }
}

test "Empty File - Read File and Find Pos of Insertion Position" {
    var allocator = std.testing.allocator;

    const file_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/mock/empty.code-snippets";
    const position = try findPositionToInsert(&allocator, file_path);

    std.debug.print("Position of second last '}}': {}\n", .{position});
}
// zig build-exe modify_snippet.zig
// ./modify_snippet
// zig test modify_snippet.zig

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
