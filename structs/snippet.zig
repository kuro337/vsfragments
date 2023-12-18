const std = @import("std");
const print = std.debug.print;

pub const Snippet = struct {
    title: []const u8,
    prefix: []const u8,
    body: [][]const u8,
    description: []const u8,
    create_flag: bool,

    pub fn format(
        snippet: Snippet,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        if (snippet.create_flag == true) {
            try writer.print("{{\n", .{});
        }
        try writer.print("\t{s}\n\t\t{s}\n\t\t\"body\": [\n", .{ snippet.title, snippet.prefix });
        for (snippet.body) |parsed_line| {
            try writer.print("\t\t\t{s}\n", .{parsed_line});
        }
        try writer.print("\t\t],\n\t\t{s}\n\t}}\n", .{snippet.description});
        if (snippet.create_flag == true) {
            try writer.print("}}\n", .{});
        }
    }

    pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]const u8 {
        var escapedLineBuilder = std.ArrayList(u8).init(allocator);
        defer escapedLineBuilder.deinit();

        // Add opening quote
        try escapedLineBuilder.append('\"');

        var spaceCount: usize = 0;
        for (line) |char| {
            switch (char) {
                ' ' => {
                    spaceCount += 1;
                    if (spaceCount == 4) {
                        // Handle tab logic
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('t');
                        spaceCount = 0;
                    } else {
                        // Append a single space
                        try escapedLineBuilder.append(' ');
                    }
                },
                '\\' => {
                    // Append a backslash to escape it, without adding any spaces
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append('\\');
                },
                '$', '"' => {
                    // Escape special characters
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append(char);
                },
                else => {
                    // Reset space counter and append other characters directly
                    spaceCount = 0;
                    try escapedLineBuilder.append(char);
                },
            }
        }

        // Add closing quote
        try escapedLineBuilder.append('\"');

        // Add comma except for the last line
        try escapedLineBuilder.append(',');

        return escapedLineBuilder.toOwnedSlice();
    }

    pub fn createFromLines(allocator: std.mem.Allocator, lines: []const []const u8, write_flag: bool) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator);

        const totalLines = lines.len;

        for (lines, 0..) |line, i| {
            var escapedLineBuilder = std.ArrayList(u8).init(allocator);
            defer escapedLineBuilder.deinit();

            // Add opening quote
            try escapedLineBuilder.append('\"');

            var spaceCount: usize = 0;
            for (line) |char| {
                switch (char) {
                    ' ' => {
                        spaceCount += 1;
                        if (spaceCount == 4) {
                            // Handle tab logic
                            try escapedLineBuilder.append('\\');
                            try escapedLineBuilder.append('t');
                            spaceCount = 0;
                        } else {
                            // Append a single space
                            try escapedLineBuilder.append(' ');
                        }
                    },
                    '\\' => {
                        // Append a backslash to escape it, without adding any spaces
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('\\');
                    },
                    '$', '"' => {
                        // Escape special characters
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append(char);
                    },
                    else => {
                        // Reset space counter and append other characters directly
                        spaceCount = 0;
                        try escapedLineBuilder.append(char);
                    },
                }
            }

            // Add closing quote
            try escapedLineBuilder.append('\"');

            // Add comma except for the last line
            if (i < totalLines - 1) {
                try escapedLineBuilder.append(',');
            }

            const finalEscapedLine = try escapedLineBuilder.toOwnedSlice();
            try parsedLines.append(finalEscapedLine);
        }

        return Snippet{
            .title = "\"Go HTTP Server Snippet\": {",
            .prefix = "\"prefix\": \"gohttpserver\",",
            .body = try parsedLines.toOwnedSlice(),
            .description = "\"description\": \"Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.\"",
            .create_flag = write_flag,
        };
    }

    pub fn createFromLinesNonANSI(allocator: std.mem.Allocator, lines: []const []const u8, write_flag: bool) !Snippet {
        var parsedLines = std.ArrayList([]const u8).init(allocator);

        const totalLines = lines.len;

        for (lines, 0..) |line, i| {
            var escapedLineBuilder = std.ArrayList(u8).init(allocator);
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

            // Add closing quote
            try escapedLineBuilder.append('\"');

            // Add comma except for the last line
            if (i < totalLines - 1) {
                try escapedLineBuilder.append(',');
            }

            const finalEscapedLine = try escapedLineBuilder.toOwnedSlice();
            try parsedLines.append(finalEscapedLine);
        }

        return Snippet{
            .title = "\"Go HTTP Server Snippet\": {",
            .prefix = "\"prefix\": \"gohttpserver\",",
            .body = try parsedLines.toOwnedSlice(),
            .description = "\"description\": \"Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.\"",
            .create_flag = write_flag,
        };
    }
};
