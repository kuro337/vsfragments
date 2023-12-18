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

const constants = @import("constants");

const printCLIFlags = @import("cli_parser").printCLIFlags;
const getFragmentFlags = @import("cli_parser").getFragmentFlags;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const fragment_flags = try getFragmentFlags(allocator);

    try switch (fragment_flags.evaluateFlags()) {
        0 => try fragment_flags.printHelp(),
        1 => try parseFileAndPrint(allocator, fragment_flags.file_path.?),
        2 => {
            //print("\n\n\x1b[97mPassed Snippet File and Output.\x1b[0m\n\n", .{});
            print("\n\n{s}", .{constants.stdout_passed_snippet_file_output});
            const input_file_path = fragment_flags.file_path orelse "";
            const output_file_path = fragment_flags.output_path orelse "";
            const confirmation_flag = fragment_flags.confirmation;
            try parseFromInputFileWriteOutput(allocator, input_file_path, output_file_path, confirmation_flag);
        },
        3 => {
            // stdout_passed_inline_text
            // print("\x1b[97mPassed Inline Snippet.\x1b[0m", .{});

            print("\n\n{s}\n", .{constants.stdout_passed_inline_text});

            if (fragment_flags.code_str) |code| {
                const split_lines = try convertInlineCodeToLines(allocator, code);
                defer allocator.free(split_lines);

                const transformed_snippet = try transformTextToFragment(allocator, split_lines);
                _ = try printFragmentBuffered(transformed_snippet);
            }
        },
        else => fragment_flags.printHelp(),
    };

    // print("Fragment Flags: {}\n", .{fragment_flags});
}

// if only input file passed
pub fn parseFileAndPrint(allocator: std.mem.Allocator, input_file_path: []const u8) !void {

    // 1. Read File -> Write Snippet to stdout

    const input_file_exists = try checkFileExists(input_file_path);

    if (input_file_exists == false) return handleInputFileNotExists(input_file_path);

    // 2. Print Snippet

    const transformed_snippet = try transformFileToFragment(allocator, input_file_path, false);
    _ = try printFragmentBufferedFileIO(transformed_snippet);
}

pub fn parseFromInputFileWriteOutput(allocator: std.mem.Allocator, input_file_path: []const u8, output_file_path: []const u8, confirmation_flag: bool) !void {

    // 1. Read File -> Return Snippet -> Set Write Flag on Fragment if passed

    const input_file_exists = try checkFileExists(input_file_path);
    if (input_file_exists == false) return handleInputFileNotExists(input_file_path);

    var transformed_snippet = try transformFileToFragment(allocator, input_file_path, confirmation_flag);

    // 2. Print Snippet

    _ = try printFragmentBufferedFileIO(transformed_snippet);

    // 3. Decide to Create New File or Write to Existing

    const output_file_exists = try checkFileExists(output_file_path);

    // Set Flag False in case -y flag was passed for existing File
    if (output_file_exists and confirmation_flag) transformed_snippet.create_flag = false;

    if (output_file_exists == false and confirmation_flag == false) { // file doesnt exist and they havent set write flag
        print("{s}", .{constants.output_file_not_exists});
        const msg_outputfile_missing = constants.msg_outputfile_missing;
        print("\n{s}\n", .{msg_outputfile_missing});
        return;
    } else if (output_file_exists == false and confirmation_flag == true) { // file doesnt exist but they want to write file
        print("\nCreating Snippets File {s} and adding Fragment.\n", .{output_file_path});

        try createSnippetsFileAndWrite(transformed_snippet, output_file_path);

        print("\x1b[92mSuccessfully Created Snippets File \x1b[0m\x1b[97m{s}\x1b[0m\n", .{output_file_path});
        return;
    }

    // if file exists and they pass the -y flag we just insert into it by continuing below flow

    const position = try findPositionToInsert(allocator, output_file_path);

    try writeSnippetToFileAtByteOffset(allocator, transformed_snippet, output_file_path, position);

    print("\nSuccessfully Updated Snippets File \x1b[92m{s}\x1b[0m\n", .{output_file_path});
}

pub fn handleInputFileNotExists(path: []const u8) void {
    print("\n\x1b[1m\x1b[31mFile Not Found\x1b[0m\n\n\x1b[31mInput File {s} does not exist at path.\x1b[0m\n", .{path});
    const INPUT_FILE_NOT_FOUND_MSG = constants.INPUT_FILE_NOT_FOUND_MSG;
    print("\n{s}\n", .{INPUT_FILE_NOT_FOUND_MSG});
    return;
}
