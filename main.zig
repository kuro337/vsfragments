const std = @import("std");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const Flags = @import("flags").Flags;
const FlagEval = @import("flags").FlagEval;

const constants = @import("constants");

const convertInlineCodeToLines = @import("json_parser").convertInlineCodeToLines;
const transformTextToFragment = @import("json_parser").transformTextToFragment;
const transformFileToFragment = @import("json_parser").transformFileToFragment;

const checkMemoryLeaks = @import("memory_mgmt").checkMemoryLeaks;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;

const checkFileExists = @import("modify_snippet").checkFileExists;
const findPositionToInsert = @import("modify_snippet").findPositionToInsert;
const writeSnippetToFileAtByteOffset = @import("modify_snippet").writeSnippetToFileAtByteOffset;

const createSnippetsFileAndWrite = @import("create_file").createSnippetsFileAndWrite;
const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;

const printInlineFragmentBuffered = @import("write_results").printInlineFragmentBuffered;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

const printCLIFlags = @import("cli_parser").printCLIFlags;
const getFragmentFlags = @import("cli_parser").getFragmentFlags;

// NOTE: use Snippet.convertFileToSnippet() everywhere - MOST efficient

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const fragment_flags = try getFragmentFlags(allocator);

    switch (fragment_flags.evalCmds()) {
        FlagEval.invalid => try fragment_flags.printHelp(),
        FlagEval.file => try parseFileAndPrint(allocator, fragment_flags.file_path.?, fragment_flags),
        FlagEval.file_out => {
            print("\n\n{s}", .{constants.stdout_passed_snippet_file_output});
            const input_file_path = fragment_flags.file_path orelse "";
            const output_file_path = fragment_flags.output_path orelse "";
            const confirmation_flag = fragment_flags.confirmation;
            _ = confirmation_flag; // autofix
            try parseFromInputFileWriteOutput(allocator, input_file_path, output_file_path, fragment_flags);
        },
        FlagEval.inline_code => {
            print("\n\n{s}\n", .{constants.stdout_passed_inline_text});

            if (fragment_flags.code_str) |code| {
                const split_lines = try convertInlineCodeToLines(allocator, code);
                defer allocator.free(split_lines);

                var transformed_snippet = try transformTextToFragment(allocator, split_lines);
                transformed_snippet.setMetadata(fragment_flags.title, fragment_flags.prefix, fragment_flags.description, fragment_flags.confirmation, fragment_flags.force);

                _ = try printInlineFragmentBuffered(transformed_snippet);
            }
        },
    }
}

// ===================================================
//                     HELPERS
// ===================================================

// if only input file passed
pub fn parseFileAndPrint(allocator: std.mem.Allocator, input_file_path: []const u8, user_args: Flags) !void {

    // 1. Read File -> Write Snippet to stdout

    const input_file_exists = try checkFileExists(input_file_path);

    if (input_file_exists == false) return handleInputFileNotExists(input_file_path);

    // 2. Print Snippet

    var transformed_snippet = try transformFileToFragment(allocator, input_file_path, false);

    transformed_snippet.setMetadata(user_args.title, user_args.prefix, user_args.description, user_args.confirmation, user_args.force);

    _ = try printFragmentBufferedFileIO(transformed_snippet);
}

pub fn parseFromInputFileWriteOutput(allocator: std.mem.Allocator, input_file_path: []const u8, output_file_path: []const u8, user_args: Flags) !void {

    // Read File -> Transform to Snippet

    const input_file_exists = try checkFileExists(input_file_path);
    if (input_file_exists == false) return handleInputFileNotExists(input_file_path);

    var transformed_snippet = try Snippet.convertFileToSnippet(allocator, input_file_path, user_args.confirmation);
    transformed_snippet.setMetadata(user_args.title, user_args.prefix, user_args.description, user_args.confirmation, user_args.force);

    // Print Transformed Snippet
    _ = try printFragmentBufferedFileIO(transformed_snippet);

    const output_file_exists = try checkFileExists(output_file_path);

    if (output_file_exists) {
        try transformed_snippet.appendSnippet(allocator, output_file_path, true);
    } else {
        print("\nCreating Snippets File {s} and adding Fragment.\n\n", .{output_file_path});

        try transformed_snippet.writeSnippet(output_file_path, true);
    }
}
