const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eql = std.mem.eql;
const Thread = std.Thread;

const Snippet = @import("structs/snippet.zig").Snippet;
const checkMemoryLeaks = @import("utils/memory_mgmt.zig").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("utils/memory_mgmt.zig").clearSliceMatrixMemory;
const readLinesFromFile = @import("utils/read_lines.zig").readLinesFromFile;

pub fn transformFileToSnippet(allocator: *const std.mem.Allocator, file_path: []const u8) !Snippet {
    const linesArrayList = try readLinesFromFile(allocator, file_path);

    defer clearSliceMatrixMemory(linesArrayList, allocator);

    print("{s}\nSuccessfully Buffered Bytes from Disk to Memory.\n{s}\nContent Read:\n{s}\n", .{ stdout_section_limiter, stdout_section_limiter, stdout_result_limiter });

    for (linesArrayList) |line| {
        print("{s}\n", .{line});
    }

    const snippet = try Snippet.fromLinesAutoMemory(allocator, linesArrayList);

    print("{s}\n\n{s}\nSuccessfully Parsed to Snippet.\nTransformed Snippet:\n{s}\n{s}\n{s}\n", .{ stdout_result_limiter, stdout_section_limiter, stdout_result_limiter, snippet, stdout_section_limiter });

    return snippet;
}

const stdout_section_limiter = "===================";
const stdout_result_limiter = "_____________________";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer checkMemoryLeaks(&gpa);

    const linesArrayList = try readLinesFromFile(&allocator, "testfile.txt");

    defer clearSliceMatrixMemory(linesArrayList, &allocator);

    print("{s}\nSuccessfully Buffered Bytes from Disk to Memory.\n{s}\nContent Read:\n{s}\n", .{ stdout_section_limiter, stdout_section_limiter, stdout_result_limiter });

    for (linesArrayList) |line| {
        print("{s}\n", .{line});
    }

    const snippet = try Snippet.fromLinesAutoMemory(&allocator, linesArrayList);

    defer clearSliceMatrixMemory(snippet.body, &allocator);

    print("{s}\n\n{s}\nSuccessfully Parsed to Snippet.\nTransformed Snippet:\n{s}\n{s}\n{s}\n", .{ stdout_result_limiter, stdout_section_limiter, stdout_result_limiter, snippet, stdout_section_limiter });
}
