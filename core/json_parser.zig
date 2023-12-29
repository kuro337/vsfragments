const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eql = std.mem.eql;
const Thread = std.Thread;

const Snippet = @import("snippet").Snippet;
const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;
const freeSlices = @import("memory_mgmt").freeSlices;

const readLinesFromFile = @import("read_lines").readLinesFromFile;
const readLinesFromFileC = @import("read_lines").readLinesFromFileC;

const stdout_section_limiter = "===================";
const stdout_result_limiter = "_____________________";

pub fn convertInlineCodeToLines(allocator: std.mem.Allocator, code_str: []const u8) ![][]const u8 {
    var splitLines = std.ArrayList([]const u8).init(allocator);
    defer splitLines.deinit();

    var split = std.mem.splitScalar(u8, code_str, '\n');

    while (split.next()) |line| {
        try splitLines.append(line);
    }

    return splitLines.toOwnedSlice();
}

pub fn transformTextToFragment(allocator: std.mem.Allocator, code_str: []const []const u8) !Snippet {
    const snippet = try Snippet.createFromLines(allocator, code_str, false);

    // print("\n{s}\n\x1b[92mSuccessfully Created Fragment.\x1b[0m\n{s}\n{}\n{s}\n", .{ stdout_section_limiter, stdout_result_limiter, snippet, stdout_section_limiter });

    return snippet;
}

// testing type change of  linesArrayList

pub fn transformFileToFragment(allocator: std.mem.Allocator, file_path: []const u8, create: bool) !Snippet {
    //const linesArrayList = try readLinesFromFile(allocator, file_path);
    const linesArrayList = try readLinesFromFileC(file_path);
    errdefer {
        freeSlices(allocator, linesArrayList);
    }

    const snippet = try Snippet.createFromLines(allocator, linesArrayList, create);

    return snippet;
}
