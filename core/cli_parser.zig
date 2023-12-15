const std = @import("std");
const clap = @import("clap");
const io = std.io;
const process = std.process;
const print = std.debug.print;

const Flags = @import("flags").Flags;

// From Zig-Clap's Docs
pub fn printCLIFlags() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-n, --number <INT>     An option parameter, which takes a value.
        \\-a, --answer <ANSWER>  An option parameter which takes an enum.
        \\-s, --string <STR>...  An option parameter which can be specified multiple times.
        \\-c --check             0 if not provided 1 if provided   
        \\<FILE>...              Extra Lines without Flags will be Printed from this 
        \\
    );

    // Declare our own parsers which are used to map the argument strings to other
    // types.
    const YesNo = enum { yes, no };
    const NullCheck = enum { null, notNull };
    _ = NullCheck;

    const parsers = comptime .{
        .STR = clap.parsers.string,
        .FILE = clap.parsers.string,
        .INT = clap.parsers.int(usize, 10),
        .ANSWER = clap.parsers.enumeration(YesNo),
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = arena.allocator(),
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        print("--help\n", .{});
    if (res.args.number) |n|
        print("--number = {}\n", .{n});

    print("--check present= {}\n", .{(res.args.c)});

    if (res.args.answer) |a| {
        print("--answer = {s}\n", .{@tagName(a)});
    } else {
        print("--answer not present\n", .{});
    }
    for (res.args.string) |s|
        print("--string = {s}\n", .{s});
    for (res.positionals) |pos|
        print("{s}\n", .{pos});

    if (res.args.help == 0 and res.args.number == null and res.args.answer == null and res.args.string.len == 0 and res.positionals.len == 0) {
        print("No flags provided.\n", .{});
        return;
    }
}

pub fn getFragmentFlags(allocator: std.mem.Allocator) !Flags {

    // ALL FLAGS  ./vsznippet-fast -h -f f -o o -l l -r r -t t -d d -p -c aaaaa qqq

    // ! IMPORTANT : Multiline Flags need to be positional

    const params = comptime clap.parseParamsComptime(
        \\-c, --code        <string>... Code stringing for direct input.
        \\-h, --help                    Display this help and exit.
        \\-f, --file         <string>    File path for input to be converted.
        \\-o, --output      <string>    File path for output.
        \\-l, --lang        <string>    Language specification.
        \\-r, --prefix       <string>    Optional prefix for snippet.
        \\-t, --title       <string>    Optional title for snippet.
        \\-d, --description <string>    Optional description for snippet.
        \\-p, --print                   Flag for printing output.
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

    if (res.args.help != 0)
        try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});

    return Flags{
        .file_path = if (res.args.file) |f| f else null,
        .output_path = if (res.args.output) |o| o else null,
        .code_str = res.args.code,
        .lang = if (res.args.lang) |l| l else null,
        .prefix = if (res.args.prefix) |r| r else null,
        .title = if (res.args.title) |t| t else null,
        .description = if (res.args.description) |d| d else null,
        .help = if (res.args.help == 1) true else false,
        .print = if (res.args.print == 1) true else false,
    };
}
