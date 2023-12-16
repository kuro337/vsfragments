const std = @import("std");
const print = std.debug.print;

const transformFileToSnippet = @import("json_parser").transformFileToSnippet;
const transformTextToFragment = @import("json_parser").transformTextToFragment;

const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

const findPositionToInsert = @import("modify_snippet").findPositionToInsert;
const writeSnippetToFileAtByteOffset = @import("modify_snippet").writeSnippetToFileAtByteOffset;

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && ./vsfragment_fast
// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && ./vsfragment_safe
// ./vsfragment_fast

// ./vsfragment_fast -f "testfile.txt" -o "populated.code-snippets" -c "example code" -l "go" -p --title "Go HTTP Server" --description "Creating a HTTP Server in Go" --prefix "gohttp"
// ./vsfragment_fast -f "testfile.txt" -o "populated.code-snippets" -l "go" -p --title "Go HTTP Server" --description "Creating a HTTP Server in Go" --prefix "gohttp"

// ./vsfragment_fast -c code -h -f file -o outputfile -l lang -r prefix -t title -d description -p
// ./vsfragment_fast -c 'code memos miiii'

// Flow 1. Get Input , Print
// ./vsfragment_fast -f ../../mock/testfile.txt

// Flow 2. Get Input , Write to File
// ./vsfragment_fast -f ../../mock/testfile.txt -o ../../mock/populated.code-snippets

const printCLIFlags = @import("cli_parser").printCLIFlags;
const getFragmentFlags = @import("cli_parser").getFragmentFlags;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fragment_flags = try getFragmentFlags(allocator);

    switch (fragment_flags.evaluateFlags()) {
        0 => fragment_flags.printHelp(),
        1 => fragment_flags.printHelp(),
        2 => {
            print("Passed Fragment File and Output\n", .{});
            const input_file_path = fragment_flags.file_path orelse "";
            const output_file_path = fragment_flags.output_path orelse "";
            try parseFromInputFileWriteOutput(input_file_path, output_file_path);
        },
        3 => {
            print("Passed Inline Snippet\n", .{});
            if (fragment_flags.code_str) |code| {
                _ = try transformTextToFragment(&allocator, code);
            }
        },
        else => fragment_flags.printHelp(),
    }

    if (fragment_flags.file_path == null) {
        fragment_flags.printHelp();
        return;
    }

    print("Fragment Flags: {}\n", .{fragment_flags});
}

pub fn parseFromInputFileWriteOutput(input_file_path: []const u8, output_file_path: []const u8) !void {
    // 0. Create Allocator for Application

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer checkMemoryLeaks(&gpa);

    // 1. Read File -> Return Snippet

    const transformed_snippet = try transformFileToSnippet(&gpa_allocator, input_file_path);
    defer clearSliceMatrixMemory(transformed_snippet.body, &gpa_allocator);

    // 2. Print Snippet
    print("Final Snippet -> Add to Snippets File.{}\n", .{transformed_snippet});

    // 3. Find Position of File to Insert Snippet
    const position = try findPositionToInsert(&gpa_allocator, output_file_path);

    std.debug.print("Position of second last '}}': {}\n", .{position});

    try writeSnippetToFileAtByteOffset(&gpa_allocator, transformed_snippet, output_file_path, position);

    print("Updated Snippets File.{s}\n", .{output_file_path}); // for now manually add ,\n at last pos + 1 - and add \n} to end
}
// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/native && ./vsfragment_fast

// curr testfile is in binary folder

// vsznippet-debug vsfragment_fast  vsznippet-safe  vsznippet-small
