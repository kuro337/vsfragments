const std = @import("std");

// zig build-exe vector.zig
// ./vector
// zig test file.zig

pub fn printControlCharFromASCIICode(char: u8) void {
    const charDesc = switch (char) {
        9 => "Tab (\\t)",
        10 => "Line Feed (\\n)",
        13 => "Carriage Return (\\r)",
        0 => "Null (NUL)",
        7 => "Bell (BEL)",
        8 => "Backspace (BS)",
        12 => "Form Feed (FF)",
        27 => "Escape (ESC)",
        127 => "Delete (DEL)",
        else => "Unknown Control Character",
    };
    _ = charDesc; // autofix
    //    std.debug.print("Control character found: '{s}' (ASCII: {d})\n", .{ charDesc, @as(u8, @intCast(char)) });
}

pub fn containsControlChars(line: []const u8) bool {
    var contains_control_chars = false;

    for (line) |char| {
        if (isControlCharacter(char)) {
            contains_control_chars = true;

            //std.debug.print("'{c}' (ASCII: {d}) detected.\n", .{ char, @as(u8, @intCast(char)) });
            //    printControlCharFromASCIICode(char);
        }
    }
    return contains_control_chars;
}

fn isControlCharacter(char: u8) bool {
    // ASCII control characters are in the range 0x00-0x1F and 0x7F.
    return char < 0x20 or char == 0x7F;
}

//pub fn main() !void {
//}

test "Contains Control Characters in Line" {
    const input_file = "mock/backup/control_char_data/contains_controlchars.txt";

    const control_char_lines = [_]u8{ 7, 8, 9, 10, 11, 12 };

    var line_buffer: [1024]u8 = undefined;
    var it = try readLines(input_file, &line_buffer, .{});
    defer it.deinit();

    var i: usize = 0;
    var curr_bad_line: usize = 0;

    while (try it.next()) |line| {
        if (containsControlChars(line)) {
            // try w.print("Curr Line:{d} Exp Line:{d}\n", .{ i, curr_bad_line });
            // try w.print("^^ line: {d} contains control chars.\n{s}\n\n", .{ i, line });

            try std.testing.expectEqual(control_char_lines[curr_bad_line], i);

            curr_bad_line += 1;
        }

        i += 1;
    }

    try checkControlChars("mock/backup/control_char_data/contains_controlchars.txt");
}
// lines 7 , 8 , 9 , 10 , 11 , 12 contain control chars
pub fn checkControlChars(file_path: []const u8) !void {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    var w = buf.writer();

    var line_buffer: [1024]u8 = undefined;

    var it = try readLines(file_path, &line_buffer, .{});
    defer it.deinit();

    var i: i32 = 0;

    while (try it.next()) |line| {

        //   std.debug.print("line: {s}\n", .{line});

        if (containsControlChars(line)) {
            try w.print("^^ line: {d} contains control chars.\n{s}\n\n", .{ i, line });
        }

        try buf.flush();
        i += 1;
    }
}

const Allocator = std.mem.Allocator;

pub const LineIterator = LineIteratorSize(4096);

// Made into a generic so that we can efficiently test files larger than buffer
pub fn LineIteratorSize(comptime size: usize) type {
    return struct {
        out: []u8,
        delimiter: u8,
        file: std.fs.File,
        buffered: std.io.BufferedReader(size, std.fs.File.Reader),

        const Self = @This();

        pub const Opts = struct {
            open_flags: std.fs.File.OpenFlags = .{},
            delimiter: u8 = '\n',
        };

        pub fn deinit(self: Self) void {
            self.file.close();
        }

        pub fn next(self: *Self) !?[]u8 {
            const delimiter = self.delimiter;

            var out = self.out;
            var written: usize = 0;

            var buffered = &self.buffered;
            while (true) {
                const start = buffered.start;
                if (std.mem.indexOfScalar(u8, buffered.buf[start..buffered.end], delimiter)) |pos| {
                    const written_end = written + pos;
                    if (written_end > out.len) {
                        return error.StreamTooLong;
                    }

                    const delimiter_pos = start + pos;
                    if (written == 0) {
                        // Optimization. We haven't written anything into `out` and we have
                        // a line. We can return this directly from our buffer, no need to
                        // copy it into `out`.
                        buffered.start = delimiter_pos + 1;
                        return buffered.buf[start..delimiter_pos];
                    } else {
                        @memcpy(out[written..written_end], buffered.buf[start..delimiter_pos]);
                        buffered.start = delimiter_pos + 1;
                        return out[0..written_end];
                    }
                } else {
                    // We didn't find the delimiter. That means we need to write the rest
                    // of our buffered content to out, refill our buffer, and try again.
                    const written_end = (written + buffered.end - start);
                    if (written_end > out.len) {
                        return error.StreamTooLong;
                    }
                    @memcpy(out[written..written_end], buffered.buf[start..buffered.end]);
                    written = written_end;

                    // fill our buffer
                    const n = try buffered.unbuffered_reader.read(buffered.buf[0..]);
                    if (n == 0) {
                        return null;
                    }
                    buffered.start = 0;
                    buffered.end = n;
                }
            }
        }
    };
}

pub fn readLines(file_path: []const u8, out: []u8, opts: LineIterator.Opts) !LineIterator {
    return readLinesSize(4096, file_path, out, opts);
}

pub fn readLinesSize(comptime size: usize, file_path: []const u8, out: []u8, opts: LineIterator.Opts) !LineIteratorSize(size) {
    const file = blk: {
        if (std.fs.path.isAbsolute(file_path)) {
            break :blk try std.fs.openFileAbsolute(file_path, opts.open_flags);
        } else {
            break :blk try std.fs.cwd().openFile(file_path, opts.open_flags);
        }
    };

    const buffered = std.io.bufferedReaderSize(size, file.reader());
    return .{
        .out = out,
        .file = file,
        .buffered = buffered,
        .delimiter = opts.delimiter,
    };
}
