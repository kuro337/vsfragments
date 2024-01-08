const std = @import("std");
const print = std.debug.print;

const constants = @import("constants");
const Snippet = @import("snippet").Snippet;
const Flags = @import("flags").Flags;
const FlagEval = @import("flags").FlagEval;

const parseCLI = @import("cli_parser").parseCLI;
const checkFileExists = @import("modify_snippet").checkFileExists;

const handleInputFileNotExists = @import("create_file").handleInputFileNotExists;
const printInlineFragmentBuffered = @import("write_results").printInlineFragmentBuffered;
const printFragmentBufferedFileIO = @import("write_results").printFragmentBufferedFileIO;

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const flags = try parseCLI(allocator);

    switch (flags.evalCmds()) {
        FlagEval.invalid => {
            try flags.printHelp();
        },

        FlagEval.file => {
            try parseFileAndPrint(allocator, flags);
        },

        FlagEval.file_out => {
            try parseFromInputFileWriteOutput(allocator, flags);
        },

        // => vsfragment -c '{text}'

        FlagEval.inline_code => {
            print("\n\n{s}\n", .{constants.stdout_passed_inline_text});

            var snippet = try Snippet.createFromString(allocator, flags.code_str, true);
            snippet.setMetadata(flags.title, flags.prefix, flags.description, flags.confirmation, flags.force);

            try printInlineFragmentBuffered(snippet);
        },
    }
}

// => vsfragment -f <file>

pub fn parseFileAndPrint(allocator: std.mem.Allocator, user_args: Flags) !void {
    if (!try checkFileExists(user_args.file_path)) {
        return handleInputFileNotExists(user_args.file_path);
    }

    var snippet = try Snippet.convertFileToSnippet(
        allocator,
        user_args.file_path,
        false,
    );

    snippet.setMetadata(
        user_args.title,
        user_args.prefix,
        user_args.description,
        user_args.confirmation,
        user_args.force,
    );

    try printFragmentBufferedFileIO(snippet);
}

// => vsfragment -f <file> -o <file>

pub fn parseFromInputFileWriteOutput(allocator: std.mem.Allocator, user_args: Flags) !void {
    print("\n\n{s}", .{constants.stdout_passed_snippet_file_output});

    if (try checkFileExists(user_args.file_path) == false) {
        return handleInputFileNotExists(user_args.file_path);
    }

    // - read file & transform to snippet
    var transformed_snippet = try Snippet.convertFileToSnippet(allocator, user_args.file_path, user_args.confirmation);
    transformed_snippet.setMetadata(user_args.title, user_args.prefix, user_args.description, user_args.confirmation, user_args.force);

    _ = try printFragmentBufferedFileIO(transformed_snippet); //  - buffered stdout write w/ snippet

    if (try checkFileExists(user_args.output_path)) { //          - update snippets output file
        try transformed_snippet.appendSnippet(allocator, user_args.output_path, true);
    } else {
        print("\nCreating Snippets File {s} and adding Fragment.\n\n", .{user_args.output_path});
        try transformed_snippet.writeSnippet(user_args.output_path, true);
    }
}
