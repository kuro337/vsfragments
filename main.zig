const std = @import("std");
const constants = @import("constants");
const print = std.debug.print;

const Snippet = @import("snippet").Snippet;
const Flags = @import("flags").Flags;
const FlagEval = @import("flags").FlagEval;

const parseCLI = @import("cli_parser").parseCLI;
const checkFileExists = @import("modify_snippet").checkFileExists;
const transformDir = @import("snippet").convertDirectoryToSnippetFile;

const handleFileNotExists = @import("create_file").handleFileNotExists;
const inlineBufferedIO = @import("write_results").inlineBufferedIO;
const writeBufferedIO = @import("write_results").writeBufferedIO;

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const flags = try parseCLI(allocator);

    switch (flags.evalCmds()) {
        FlagEval.file => { // => vsfragment -f <file>
            try parseFileStreamOutput(allocator, flags);
        },

        FlagEval.file_out => { // => vsfragment -f <file> -o <file>
            try parseInputWriteOutput(allocator, flags);
        },

        FlagEval.dir => { // => vsfragment --dir <path>
            _ = try transformDir(flags.dir_path, flags.output_path);
        },

        FlagEval.inline_code => { // => vsfragment -c '{text}'
            print("{s}", .{constants.stdout_inline});
            var snippet = try Snippet.createFromString(allocator, flags.code_str, true);
            snippet.setMetadata(flags.title, flags.prefix, flags.description, flags.confirmation, flags.force);
            try inlineBufferedIO(snippet);
        },

        FlagEval.invalid => {
            try flags.printHelp();
        },
    }
}

pub fn parseFileStreamOutput(allocator: std.mem.Allocator, args: Flags) !void {
    if (!try checkFileExists(args.file_path))
        return handleFileNotExists(args.file_path);

    var snippet = try Snippet.convertFileToSnippet(allocator, args.file_path, false);
    snippet.setMetadata(args.title, args.prefix, args.description, args.confirmation, args.force);

    try writeBufferedIO(snippet);
}

pub fn parseInputWriteOutput(allocator: std.mem.Allocator, args: Flags) !void {
    print("{s}", .{constants.stdout_flags_f_o});

    if (!try checkFileExists(args.file_path))
        return handleFileNotExists(args.file_path);

    var snippet = try Snippet.convertFileToSnippet(allocator, args.file_path, args.confirmation);
    snippet.setMetadata(args.title, args.prefix, args.description, args.confirmation, args.force);

    try writeBufferedIO(snippet); // - buffer snippet stdout

    switch (try checkFileExists(args.output_path)) {
        true => try snippet.appendSnippet(allocator, args.output_path, true),
        false => try snippet.writeSnippet(args.output_path, true),
    }
}
