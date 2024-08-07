const std = @import("std");
const clap = @import("clap");
const io = std.io;
const process = std.process;
const print = std.debug.print;

const Flags = @import("flags").Flags;
pub fn parseCLI(allocator: std.mem.Allocator) !Flags {

    // ALL FLAGS  ./vsznippet-fast -h -f f -o o -l l -r r -t t -d d -p -c aaaaa qqq

    // ! IMPORTANT : Multiline Flags need to be positional and can only be passed as Single Arg

    // -c code -h help -f file -o outputfile -l lang -r prefix -t title -d description -p
    const params = comptime clap.parseParamsComptime(
        \\-c, --code        <string>    Code stringing for direct input.
        \\-h, --help                    Display this help and exit.
        \\-f, --file         <string>    File path for input to be converted.
        \\-o, --output      <string>    File path for output.
        \\-i, --dir         <string>    File path for Full Directory.
        \\-l, --lang        <string>    Language specification.
        \\-r, --prefix       <string>    Optional prefix for snippet.
        \\-z, --pfx          <string>    Optional prefixes for snippet.
        \\-t, --title       <string>    Optional title for snippet.
        \\-d, --desc        <string>    Optional description for snippet.
        \\-p, --print                   Flag for printing output.
        \\-y, --y                       Confirmation Flag for creating the Snippets File.
        \\-x, --force                   Force Flag for Appending to Invalid Snippets Files.
        \\-n, --time                    Add the Timestamp to the Generated Snippet
        \\-x, --disable                 Disable Guidance Messages
        \\ 
    );

    const parsers = comptime .{
        .string = clap.parsers.string,
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.pfx) |x| {
        std.debug.print("Pfixes: {s}\n", .{x});
    }

    return Flags{
        .file_path = if (res.args.file) |f| f else "",
        .dir_path = if (res.args.dir) |d| d else "",
        .output_path = if (res.args.output) |o| o else "",
        .code_str = if (res.args.code) |c| c else "",
        .lang = if (res.args.lang) |l| l else "",
        .prefix = if (res.args.prefix) |r| r else "",
        .title = if (res.args.title) |t| t else "",
        .description = if (res.args.desc) |d| d else "",
        .time = if (res.args.time == 1) true else false,
        .help = if (res.args.help == 1) true else false,
        .print = if (res.args.print == 1) true else false,
        .confirmation = if (res.args.y == 1) true else false,
        .force = if (res.args.force == 1) true else false,
        .disable_help = if (res.args.disable == 1) true else false,
    };
}
