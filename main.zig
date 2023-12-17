const std = @import("std");
const print = std.debug.print;
const Snippet = @import("snippet").Snippet;

const convertInlineCodeToLines = @import("json_parser").convertInlineCodeToLines;
const transformTextToFragment = @import("json_parser").transformTextToFragment;
const transformFileToFragment = @import("json_parser").transformFileToFragment;

const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

const checkFileExists = @import("modify_snippet").checkFileExists;
const findPositionToInsert = @import("modify_snippet").findPositionToInsert;
const writeSnippetToFileAtByteOffset = @import("modify_snippet").writeSnippetToFileAtByteOffset;
const createSnippetsFileAndWrite = @import("create_file").createSnippetsFileAndWrite;

const printFragmentBuffered = @import("write_results").printFragmentBuffered;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

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

// Flow 3. Empty File , But Exists
// ./vsfragment_fast -f ../../mock/testfile.txt -o ../../mock/pure.code-snippets

const printCLIFlags = @import("cli_parser").printCLIFlags;
const getFragmentFlags = @import("cli_parser").getFragmentFlags;
const stdout_init_msg = @import("constants").stdout_init_msg;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const fragment_flags = try getFragmentFlags(allocator);

    print("\n{s}", .{stdout_init_msg});

    switch (fragment_flags.evaluateFlags()) {
        0 => fragment_flags.printHelp(),
        1 => fragment_flags.printHelp(),
        2 => {
            print("\x1b[97mPassed Snippet File and Output.\x1b[0m", .{});
            const input_file_path = fragment_flags.file_path orelse "";
            const output_file_path = fragment_flags.output_path orelse "";
            const confirmation_flag = fragment_flags.confirmation;
            try parseFromInputFileWriteOutput(allocator, input_file_path, output_file_path, confirmation_flag);
        },
        3 => {
            print("\x1b[97mPassed Inline Snippet.\x1b[0m", .{});
            if (fragment_flags.code_str) |code| {
                const split_lines = try convertInlineCodeToLines(allocator, code);
                defer allocator.free(split_lines);

                const transformed_snippet = try transformTextToFragment(allocator, split_lines);
                _ = try printFragmentBuffered(transformed_snippet);
                // _ = try writeResults(transformed_snippet);
            }
        },
        else => fragment_flags.printHelp(),
    }

    // print("Fragment Flags: {}\n", .{fragment_flags});
}

pub fn parseFromInputFileWriteOutput(allocator: std.mem.Allocator, input_file_path: []const u8, output_file_path: []const u8, confirmation_flag: bool) !void {

    // 1. Read File -> Return Snippet -> Set Write Flag on Fragment if passed

    const transformed_snippet = try transformFileToFragment(allocator, input_file_path, confirmation_flag);

    // 2. Print Snippet

    _ = try printFragmentBufferedFileIO(transformed_snippet);

    // 3. Decide to Create New File or Write to Existing

    const file_exists = try checkFileExists(output_file_path);

    if (file_exists == false and confirmation_flag == false) { // file doesnt exist and they havent set write flag
        print("\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mOutput Path Snippets File does not exist.\x1b[0m\n", .{});
        const msg_outputfile_missing = @import("constants").msg_outputfile_missing;
        print("\n{s}\n", .{msg_outputfile_missing});
        return;
    } else if (confirmation_flag == true) { // file doesnt exist but they want to write file
        print("\nCreating Snippets File {s} and adding Fragment.\n", .{output_file_path});

        try createSnippetsFileAndWrite(transformed_snippet, output_file_path);

        print("\x1b[92mSuccessfully Created Snippets File \x1b[0m\x1b[97m{s}\x1b[0m\n", .{output_file_path});
        return;
    }

    const position = try findPositionToInsert(allocator, output_file_path);

    try writeSnippetToFileAtByteOffset(allocator, transformed_snippet, output_file_path, position);

    print("\x1b[92mSuccessfully Updated Snippets File \x1b[0m\x1b[97m{s}\x1b[0m\n", .{output_file_path});
}
