const std = @import("std");
const print = std.debug.print;

pub const Snippet = struct {
    title: []const u8,
    prefix: []const u8,
    body: [][]const u8,
    description: []const u8,

    pub fn format(
        snippet: Snippet,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{s}\n{s}\n\"body\": [\n", .{ snippet.title, snippet.prefix });
        for (snippet.body) |parsed_line| {
            try writer.print("  {s}\n", .{parsed_line});
        }
        try writer.print("],\n{s}\n}}\n", .{snippet.description});
    }

    pub fn fromLinesAutoMemory(allocator: *const std.mem.Allocator, lines: [][]const u8) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator.*);

        for (lines) |line| {
            var escapedLineBuilder = std.ArrayList(u8).init(allocator.*);
            defer escapedLineBuilder.deinit();

            // Add opening quote
            try escapedLineBuilder.append('\"');

            var spaceCount: usize = 0;
            for (line) |char| {
                switch (char) {
                    ' ' => {
                        spaceCount += 1;
                        if (spaceCount == 4) {
                            try escapedLineBuilder.append('\\');
                            try escapedLineBuilder.append('t');
                            spaceCount = 0;
                        }
                    },
                    '\\' => {
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('\\');
                    },
                    '$', '"' => {
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append(char);
                    },
                    else => {
                        if (spaceCount > 0 and spaceCount < 4) {
                            while (spaceCount > 0) {
                                try escapedLineBuilder.append(' ');
                                spaceCount -= 1;
                            }
                        }
                        try escapedLineBuilder.append(char);
                    },
                }
            }

            // Add closing quote and comma
            try escapedLineBuilder.append('\"');
            try escapedLineBuilder.append(',');

            const finalEscapedLine = try escapedLineBuilder.toOwnedSlice();
            try parsedLines.append(finalEscapedLine);
        }

        return Snippet{
            .title = "\"Zig Snippet\":{",
            .prefix = "\"prefix\": \"testparse\",",
            .body = try parsedLines.toOwnedSlice(),
            .description = "\"description\":\"Log output to console\"",
        };
    }

    pub fn fromLinesManualMemory(allocator: *const std.mem.Allocator, lines: [][]const u8) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator.*);

        for (lines) |line| {

            // Instead ArrayList Manages Memory Automatically
            //var escaped_line = std.ArrayList([]const u8).init(allocator.*);

            // Allocate more space for the added characters and escaped characters
            var escaped_line = try allocator.alloc(u8, line.len * 2 + 3); // Extra space for quotes and comma
            defer allocator.free(escaped_line);

            var j: usize = 0;

            // Add opening quote
            escaped_line[j] = '\"';
            j += 1;

            var space_count: usize = 0;
            for (line) |char| {
                switch (char) {
                    ' ' => {
                        space_count += 1;
                        if (space_count == 4) {
                            escaped_line[j] = '\\';
                            j += 1;
                            escaped_line[j] = 't';
                            j += 1;
                            space_count = 0;
                        }
                    },
                    '\\' => {
                        escaped_line[j] = '\\';
                        j += 1;
                        escaped_line[j] = '\\';
                        j += 1;
                    },
                    '$', '"' => {
                        escaped_line[j] = '\\';
                        j += 1;
                        escaped_line[j] = char;
                        j += 1;
                    },
                    else => {
                        if (space_count > 0 and space_count < 4) {
                            while (space_count > 0) {
                                escaped_line[j] = ' ';
                                j += 1;
                                space_count -= 1;
                            }
                        }
                        escaped_line[j] = char;
                        j += 1;
                    },
                }
            }
            // Handle remaining spaces
            while (space_count > 0) {
                escaped_line[j] = ' ';
                j += 1;
                space_count -= 1;
            }

            // Add closing quote and comma
            escaped_line[j] = '\"';
            j += 1;
            escaped_line[j] = ',';
            j += 1;

            print("Escaped Line: {s}\n", .{escaped_line[0..j]});

            const parsed_line_known_size = try allocator.alloc(u8, j);
            std.mem.copy(u8, parsed_line_known_size, escaped_line[0..j]);

            try parsedLines.append(parsed_line_known_size[0..j]);
        }
        return Snippet{
            .title = "\"Zig Snippet\":{",
            .prefix = "\"prefix\": \"testparse\",",
            .body = try parsedLines.toOwnedSlice(),
            .description = "\"description\":\"Log output to console\"",
        };
    }
};
