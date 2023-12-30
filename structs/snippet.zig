const std = @import("std");
const print = std.debug.print;

pub const Snippet = struct {
    title: []const u8,
    prefix: []const u8,
    body: [][]const u8,
    description: []const u8,
    create_flag: bool,

    //     .title = "\"Go HTTP Server Snippet\": {",
    //     .title = "  Go HTTP Server Snippet     ",
    //               \"                      \": {

    //     .prefix = "\"prefix\": \"gohttpserver\",",
    //     .prefix = "             gohttpserver   ",
    //               \"prefix\": \"            \",",

    //     .body = try parsedLines.toOwnedSlice(),

    //     .description = "\"description\": \"Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.\"",
    //     .description = "                   {desc}\"",
    //                  = "\"description\": \"      \"",

    //     .create_flag = write_flag,
    // };

    pub fn format(
        snippet: Snippet,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        if (snippet.create_flag == true) {
            try writer.print("{{\n", .{});
        }
        try writer.print("\t\"{s}\": {{\n\t\t\"prefix\": \"{s}\",\n\t\t\"body\": [\n", .{ snippet.title, snippet.prefix });
        for (snippet.body) |parsed_line| {
            try writer.print("\t\t\t{s}\n", .{parsed_line});
        }
        try writer.print("\t\t],\n\t\t\"description\": \"{s}\"\n\t}}\n", .{snippet.description});
        if (snippet.create_flag == true) {
            try writer.print("}}\n", .{});
        }
    }

    pub fn setMetadata(self: *Snippet, title: ?[]const u8, prefix: ?[]const u8, description: ?[]const u8) void {
        if (title) |newTitle| {
            self.title = newTitle;
        }
        if (prefix) |newPrefix| {
            self.prefix = newPrefix;
        }
        if (description) |newDescription| {
            self.description = newDescription;
        }
    }

    pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]const u8 {
        var escapedLineBuilder = std.ArrayList(u8).init(allocator);
        defer escapedLineBuilder.deinit();

        // Add opening quote
        try escapedLineBuilder.append('\"');

        var prev_backslash_index: usize = 0;

        var spaceCount: usize = 0;
        for (line, 0..) |char, i| {
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
                    if (i == prev_backslash_index + 1) {
                        try escapedLineBuilder.append('\\');
                        try escapedLineBuilder.append('\\');
                    }
                    prev_backslash_index = i;
                },
                '"' => {
                    // Escape special characters
                    try escapedLineBuilder.append('\\');
                    try escapedLineBuilder.append(char);
                },
                '$' => { // prev above block has '$','"' together - this one is new for $
                    try escapedLineBuilder.append('\\');
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
        defer parsedLines.deinit();

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
            .title = "Go HTTP2 Server Snippet",
            .prefix = "gohttpserver",
            .body = try parsedLines.toOwnedSlice(),
            .description = "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.",
            .create_flag = write_flag,
        };
    }

    pub fn createFromSingleString(allocator: std.mem.Allocator, input: [*c]const u8, write_flag: bool) !Snippet {

        // Convert Input to a Zig String
        const cStringSlice: []const u8 = std.mem.span(input);

        const split_lines = try convertStringToStringSlice(allocator, cStringSlice);
        defer allocator.free(split_lines);

        if (write_flag == true) {
            const out = std.io.getStdOut();
            var buf = std.io.bufferedWriter(out.writer());
            //var w = buf.writer();
            try buf.writer().print("Direct String Received in Snippet from JS-C: \n{s}\n", .{cStringSlice});
            try buf.flush();
        }

        const snippet = try Snippet.createFromLines(allocator, split_lines, write_flag);

        return snippet;
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
            .title = "Go HTTP2 Server Snippet",
            .prefix = "gohttpserver",
            .body = try parsedLines.toOwnedSlice(),
            .description = "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.",
            .create_flag = write_flag,
        };
    }

    //     .title = "\"Go HTTP Server Snippet\": {",
    //     .title = "  Go HTTP Server Snippet     ",
    //               \"                      \": {

    //     .prefix = "\"prefix\": \"gohttpserver\",",
    //     .prefix = "             gohttpserver   ",
    //               \"prefix\": \"            \",",

    //     .body = try parsedLines.toOwnedSlice(),

    //     .description = "\"description\": \"Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly.\"",
    //     .description = "                   {desc}\"",
    //                  = "\"description\": \"      \"",

    //     .create_flag = write_flag,
    // };

    pub fn toString(snippet: Snippet, allocator: std.mem.Allocator) ![]u8 {
        var builder = std.ArrayList(u8).init(allocator);
        defer builder.deinit();

        try builder.appendSlice("{\n");

        try builder.appendSlice("\t\"");
        try builder.appendSlice(snippet.title);
        try builder.appendSlice("\": {\n\t\t\"prefix\": \"");
        try builder.appendSlice(snippet.prefix);
        try builder.appendSlice("\",\n\t\t\"body\": [\n");

        for (snippet.body) |line| {
            try builder.appendSlice("\t\t\t");
            try builder.appendSlice(line);
            try builder.appendSlice("\n");
        }

        try builder.appendSlice("\t\t],\n\t\t\"description\": \"");
        try builder.appendSlice(snippet.description);
        try builder.appendSlice("\"\n\t}\n}\n");

        return builder.toOwnedSlice();
    }

    pub fn toCStr(snippet: Snippet, allocator: std.mem.Allocator) [*:0]const u8 {
        var out = std.ArrayList(u8).initCapacity(allocator, 4096) catch unreachable;
        defer out.deinit();

        snippet.toWriter(out.writer()) catch unreachable;
        out.append(0) catch unreachable; // c-str sentinel terminater 0

        const final_buf = out.toOwnedSlice() catch unreachable;

        //return final_buf.ptr doesnt work because we need to coerce the type to be 0 sentinel terminated

        const cstr = final_buf[0 .. final_buf.len - 1 :0]; // validate sentinel termination

        return cstr.ptr;
    }

    pub fn toStr(snippet: Snippet, allocator: std.mem.Allocator) []const u8 {
        var out = std.ArrayList(u8).initCapacity(allocator, 4096) catch unreachable;
        defer out.deinit();

        snippet.toWriter(out.writer()) catch unreachable;
        out.append(0) catch unreachable;

        const final_buf = out.toOwnedSlice() catch unreachable;

        return final_buf;

        // @Usage

        //  const s_str = snippet.toStr(allocator);
        //  std.debug.print("normal str:\n{s}\n", .{s_str});
    }

    pub fn toWriter(snippet: Snippet, writer: anytype) @TypeOf(writer).Error!void {
        try writer.writeAll("{\n");

        try writer.writeAll("\t");
        try writer.writeAll(snippet.title);
        try writer.writeAll("\n\t\t");
        try writer.writeAll(snippet.prefix);
        try writer.writeAll("\n\t\t\"body\": [\n");

        for (snippet.body) |line| {
            try writer.writeAll("\t\t\t");
            try writer.writeAll(line);
            try writer.writeAll("\n");
        }

        try writer.writeAll("\t\t],\n\t\t");
        try writer.writeAll(snippet.description);
        try writer.writeAll("\n\t}\n}\n");
    }
};

test "Test Snippet Parse From Direct C String" {
    const mock_selection =
        \\hello
        \\world
        \\\\\\\\
        \\\n\n\n\n\n
        \\nextline nextline 
        \\oneline \n\n    aaaa\\\\ \ttttt XXXX
        \\oneline \n\n    aaaa\\\\ \ttttt XXXX
        \\          \!!!!!,,,,,
        \\
        \\
    ;

    const allocator = std.testing.allocator;

    const cString: [*c]const u8 = "Your test string here";
    const cStringSlice: []const u8 = std.mem.span(cString);

    const split_s = try convertStringToStringSlice(allocator, cStringSlice);
    defer allocator.free(split_s);

    acceptStringSlicesConst(split_s);

    try Snippet.createFromSingleString(allocator, mock_selection, true);
    try Snippet.createFromSingleString(allocator, cString, true);
}

// ============== STRING CONVERSION UTILS ==============

pub fn convertStringToStringSlice(allocator: std.mem.Allocator, code_str: []const u8) ![][]const u8 {
    var splitLines = std.ArrayList([]const u8).init(allocator);
    defer splitLines.deinit();

    var split = std.mem.splitScalar(u8, code_str, '\n');

    while (split.next()) |line| {
        try splitLines.append(line);
    }

    return splitLines.toOwnedSlice();
}

pub fn acceptStringSlicesConst(str_slices: []const []const u8) void {
    const len = str_slices.len;
    std.debug.print("Length of Passed String Slices {d}\n", .{len});

    for (str_slices) |st| {
        std.debug.print("{s}\n", .{st});
    }
}
// ============================================

pub fn testSnippetToString(allocator: std.mem.Allocator, snippet: Snippet) !void {
    const to_string = try snippet.toString(allocator);

    print("toString() Snippet \n\n{s}\n", .{to_string});

    const SnippetContent = struct {
        prefix: []u8,
        body: [][]u8,
        description: []u8,
    };

    // DEFINE JSON STRING , PARSE INTO JSON VALUE (noprint) - THEN STRINGIFY JSON VALUE
    const json =
        \\{"prefix": "gohttpserver","body": ["hello"],"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."}
    ;

    const parsed = std.json.parseFromSlice(
        SnippetContent,
        allocator,
        json,
        .{},
    ) catch |err| {
        std.debug.print("Error for Parse: {}\n", .{err});
        return;
    };

    defer parsed.deinit();

    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());

    try std.json.stringify(parsed.value, .{}, string.writer());

    print("Stringified {s}\n", .{string.items});

    //const parsed_snip = parsed.value;

    //print("Parsed Struct {}\n", .{parsed_snip});
    print("Parsed No Err\n", .{});

    // ===================================================
    // ===================================================

    const ParseObject = struct {
        thisisunknown: SnippetContent,
    };

    const json_nested =
        \\{
        \\"thisisunknown": 
        \\  {
        \\      "prefix": "anystring",
        \\      "body": ["array","values"],
        \\      "description": "any string here"
        \\  }
        \\}
    ;

    const nested_parse = std.json.parseFromSlice(
        ParseObject,
        allocator,
        json_nested,
        .{},
    ) catch |err| {
        std.debug.print("Error for Nested Parse: {}\n", .{err});
        return;
    };

    defer nested_parse.deinit();

    var n_buf: [4096]u8 = undefined;
    var fba_n = std.heap.FixedBufferAllocator.init(&n_buf);
    var string_n = std.ArrayList(u8).init(fba_n.allocator());

    try std.json.stringify(nested_parse.value, .{}, string_n.writer());

    print("Stringified {s}\n", .{string_n.items});

    print("Parsed nested No Err\n", .{});
}
