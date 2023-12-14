const std = @import("std");

pub fn readLinesFromFile(allocator: *const std.mem.Allocator, filename: []const u8) ![][]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var lines = std.ArrayList([]const u8).init(allocator.*);

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        // Copy Line we read from Disk to Buffer to the final ArrayList
        const lineCopy = try allocator.alloc(u8, line.len);
        std.mem.copy(u8, lineCopy, line);

        // Append the line to the ArrayList
        try lines.append(lineCopy[0..line.len]);
    }

    return lines.toOwnedSlice(); // return bounded slice - caller needs to free memory for each line + full slice
}
