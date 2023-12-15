const std = @import("std");
const print = std.debug.print;

const transformFileToSnippet = @import("json_parser").transformFileToSnippet;

const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

const findPositionToInsert = @import("modify_snippet").findPositionToInsert;
const writeSnippetToFileAtByteOffset = @import("modify_snippet").writeSnippetToFileAtByteOffset;

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin && ./vsznippet-fast

// ./vsznippet-fast

// ./vsznippet-fast -f "testfile.txt" -o "populated.code-snippets" -c "example code" -l "go" -p --title "Go HTTP Server" --description "Creating a HTTP Server in Go" --prefix "gohttp"
// ./vsznippet-fast -f "testfile.txt" -o "populated.code-snippets" -l "go" -p --title "Go HTTP Server" --description "Creating a HTTP Server in Go" --prefix "gohttp" -c 'example code more lines to print' adasd 'asdasd'
// ./vsznippet-fast -f "testfile.txt" -o "populated.code-snippets" -l "go" -p --title "Go HTTP Server" --description "Creating a HTTP Server in Go" --prefix "gohttp"

// ./vsznippet-fast -h -f f -o o -l l -r r -t t -d d -p -c aaaaa qqq
const printCLIFlags = @import("cli_parser").printCLIFlags;
const getFragmentFlags = @import("cli_parser").getFragmentFlags;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // try printCLIFlags();

    const fragment_flags = try getFragmentFlags(allocator);

    print("Fragment Flags: {}\n", .{fragment_flags});

    // return;

    // print("{s}\n", .{"Running Vector Snippet Parser"});

    // // 0. Create Allocator for Application

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    // defer _ = gpa.deinit();
    // defer checkMemoryLeaks(&gpa);

    // // 1. Read File -> Return Snippet

    // const transformed_snippet = try transformFileToSnippet(&allocator, "testfile.txt");
    // defer clearSliceMatrixMemory(transformed_snippet.body, &allocator);

    // // 2. Print Snippet
    // print("Final Snippet -> Add to Snippets File.{}\n", .{transformed_snippet});

    // // 3. Find Position of File to Insert Snippet
    // const file_path = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/mock/populated.code-snippets";
    // const position = try findPositionToInsert(&allocator, file_path);

    // std.debug.print("Position of second last '}}': {}\n", .{position});

    // try writeSnippetToFileAtByteOffset(&allocator, transformed_snippet, file_path, position);

    // print("Updated Snippets File.{s}\n", .{file_path}); // for now manually add ,\n at last pos + 1 - and add \n} to end

}

// $ zig build  --summary all

// cd /Users/kuro/Documents/Code/Zig/FileIO/vsfragments/zig-out/bin && ./vsznippet-fast

// curr testfile is in binary folder

// vsznippet-debug vsznippet-fast  vsznippet-safe  vsznippet-small
