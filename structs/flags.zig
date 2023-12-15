const std = @import("std");
const print = std.debug.print;

pub const Flags = struct {
    file_path: ?[]const u8 = null, // Optional file path for input
    output_path: ?[]const u8 = null, // Optional file path for output
    code_str: ?[]const []const u8 = null, // Optional code string for direct input
    lang: ?[]const u8 = null, // Optional language specification
    help: bool = false, // Flag for printing output
    print: bool = false, // Flag for printing output
    title: ?[]const u8 = null, // Optional title for snippet
    description: ?[]const u8 = null, // Optional description for snippet
    prefix: ?[]const u8 = null, // Optional prefix for snippet

    pub fn format(
        self: Flags,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("Flags:\n", .{});
        if (self.file_path) |fp| try writer.print("  File Path: {s}\n", .{fp});
        if (self.output_path) |op| try writer.print("  Output Path: {s}\n", .{op});
        if (self.lang) |lg| try writer.print("  Language: {s}\n", .{lg});
        try writer.print("  Print: {}\n", .{self.print});
        try writer.print("  Help: {}\n", .{self.help});
        if (self.title) |t| try writer.print("  Title: {s}\n", .{t});
        if (self.description) |d| try writer.print("  Description: {s}\n", .{d});
        if (self.prefix) |p| try writer.print("  Prefix: {s}\n", .{p});
        if (self.code_str) |cs|
            for (cs) |line| try writer.print("  Code String: {s}\n", .{line});
    }
};

// Flow 1. Pass Input File and Output File [ -f , -o ]  [ --file , -output ]

// ./vsfragment -f testfile.txt -o populated.code-snippets

// Flow 2. Pass Code Directly and Pretty Print it       [ -c ]  [ --code ]

// ./vsfragment -c <multilinepossiblestring>

// Flow 3. Convert file, Update Output & Print          [ -f , -o , -p ]  [ --file , -output , --print ]

// ./vsfragment -f testfile.txt -o go.code-snippets -p

// Flow 4. Pass Input File Only                        [ -f ]  [ --file ]
//(Print it if only input file is passed)

// ./vsfragment -f testfile.txt

// Flow 5. Pass Input File and Specify Lang Only       [ -f , -l ]  [ --file , -lang ]
// (AutoDetect Snippets File and Update)

// ./vsfragment -f testfile.txt -l go

// Flow 6. Input,Output, and Fragment Metadata [ -f , -o ]  [ --file , -output , --prefix , --title , --description ]
// ./vsfragment -f testfile.txt -l go -o output.txt --prefix gohttp --title 'Go Web Server' --description 'Creating a HTTP Server in Go'

// Flags {
//     file_path: "testfile.txt",
//     vs_snippets_path: "vsfragments/mock/populated.code-snippets"
//     code_str: null,   'multilinepossiblestring'
//     lang: null,        go 'go' "go"
//     print: null,       -p --print
//     help: null,        -h --help
//     format:null,       -fmt --format
//     prefix: null,       gohttp
//     title: null,       "Go HTTP Server"
//     description: null, "Creating a HTTP Server in Go"
// };
// }
