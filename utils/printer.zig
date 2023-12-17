const std = @import("std");
const Snippet = @import("snippet").Snippet;
const print = std.debug.print;

pub fn Printer(comptime WriterType: type) type {
    return struct {
        writer: WriterType,
        allocator: std.mem.Allocator,

        pub fn init(writer: WriterType) @This() { //@This() refers to this inner struct
            return .{ .writer = writer };
        }
        //And so forth...
    };
}

pub fn printColoredText(writer: anytype, colorCode: []const u8, text: []const u8) !void {
    try writer.print("{s}{s}{s}", .{ colorCode, text, "\x1b[0m" });
}

pub fn printSuccess(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[92m", text); // Bright green for success
}

pub fn printHighlighted(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[96m", text); // Light blue for highlighted text
}

pub fn printInfo(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[97m", text); // Bright white for info
}

pub fn printError(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[91m", text); // Bright red for error
}

pub fn printBold(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[1m", text); // Bold text
}

pub fn printFaded(writer: anytype, text: []const u8) !void {
    try printColoredText(writer, "\x1b[90m", text); // Dark gray (faded) text
}
