const std = @import("std");
const print = std.debug.print;
const Snippet = @import("snippet").Snippet;
const constants = @import("constants");

pub fn createSnippetsFileAndWrite(snippet: Snippet, output_file_path: []const u8) !void {
    const file = try std.fs.createFileAbsolute(output_file_path, .{});

    defer file.close();

    const formatOptions = std.fmt.FormatOptions{};

    // Write the snippet to the file
    try snippet.format("", formatOptions, file.writer());
}

pub fn handleFileNotExists(path: []const u8) void {
    print("\n\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mInput File {s} does not exist at path.\x1b[0m\n", .{path});
    const INPUT_FILE_NOT_FOUND_MSG = constants.INPUT_FILE_NOT_FOUND_MSG;
    print("\n{s}\n", .{INPUT_FILE_NOT_FOUND_MSG});
    return;
}

test "createFile, write, seekTo, read" {
    const file = try std.fs.cwd().createFile(
        "junk_file.txt",
        .{ .read = true },
    );
    defer file.close();

    const bytes_written = try file.writeAll("Hello File!");
    _ = bytes_written;

    var buffer: [100]u8 = undefined;
    try file.seekTo(0);
    const bytes_read = try file.readAll(&buffer);

    try std.testing.expect(std.mem.eql(u8, buffer[0..bytes_read], "Hello File!"));
}
