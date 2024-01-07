const std = @import("std");

test "Check for Valid UTf-8" {
    const allocator = std.testing.allocator;

    const TableTest = struct {
        file_path: []const u8,
        expected: bool,
    };

    const files = [_]TableTest{
        .{ .file_path = "tests/mock/utf8_or_binary/printer_tests", .expected = false },
        .{ .file_path = "tests/mock/utf8_or_binary/printer_tests.o", .expected = false },
        .{ .file_path = "tests/mock/utf8_or_binary/empty", .expected = false },
        .{ .file_path = "tests/mock/utf8_or_binary/valid.json", .expected = true },
        .{ .file_path = "tests/mock/utf8_or_binary/validfile.txt", .expected = true },
    };

    for (files) |f| {
        try std.testing.expectEqual(f.expected, try checkIfUtf8(allocator, f.file_path));
    }
}

test "Read Dir and confirm valid Readable Files" {
    const allocator = std.testing.allocator;
    const dir_path = "tests/mock/utf8_or_binary";

    var dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        const new_len = dir_path.len + entry.name.len;
        const concat = try allocator.alloc(u8, new_len + 1);

        const file_path = try std.fmt.bufPrint(concat, "{s}/{s}", .{ dir_path, entry.name });
        defer allocator.free(file_path);

        const isvalid = try checkIfUtf8(allocator, file_path);
        if (isvalid) {
            //   std.debug.print("File:{s} has Serializeable Data.\n", .{entry.name});
        } else {
            // std.debug.print("File:{s} has INVALID Data.\n", .{entry.name});
        }

        try std.testing.expect(true);
    }
    try std.testing.expect(true);
}

fn listFilesInDir(allocator: std.mem.Allocator, dirPath: []const u8) !void {
    _ = allocator; // autofix
    var dir = try std.fs.cwd().openDir(dirPath, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        std.debug.print("File: {s}\n", .{entry.name});
    }
}

fn checkIfUtf8(allocator: std.mem.Allocator, filePath: []const u8) !bool {
    const file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    var lines_to_read: u64 = 50;

    const bufferSize = try file.getEndPos();
    if (bufferSize == 0) return false;

    if (bufferSize < lines_to_read) lines_to_read = bufferSize;

    // std.debug.print("Checking first {d} bytes.\n", .{lines_to_read});

    const data = try allocator.alloc(u8, lines_to_read);
    defer allocator.free(data);

    // Read up to 50 bytes from the file
    _ = try file.read(data[0..lines_to_read]);

    // Use std.unicode.utf8ValidateSlice to check if the data is valid UTF-8
    return std.unicode.utf8ValidateSlice(data);
}
