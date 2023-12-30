const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eql = std.mem.eql;
const Thread = std.Thread;
const readLinesFromFile = @import("read_lines").readLinesFromFile;
const clearSliceMatrixMemory = @import("memory_mgmt").clearSliceMatrixMemory;
const Snippet = @import("snippet").Snippet;
const Coord = @import("coord").Coord;

test "Read File and Create Snippet" {
    const lines = try readLinesFromFile(std.testing.allocator, "tests/testfile.txt");
    defer clearSliceMatrixMemory(lines, std.testing.allocator);

    for (lines) |line| {
        _ = line; // autofix

        //print("Line: {s}\n", .{line});
    }
}

test "Json Parse" {
    const parsed = try std.json.parseFromSlice(
        Coord,
        test_allocator,
        \\{ "lat": 40.684540, "long": -74.401422 }
    ,
        .{},
    );
    defer parsed.deinit();

    const place = parsed.value;

    // print("Parsed Struct {}\n", .{place});
    try expect(place.lat == 40.684540);
    try expect(place.long == -74.401422);
}

test "JSON Stringify" {
    const x = Coord{
        .lat = 51.997664,
        .long = -0.740687,
    };

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(x, .{}, string.writer());

    // print("Stringified {s}\n", .{string.items});

    try expect(eql(u8, string.items,
        \\{"lat":5.199766540527344e+01,"long":-7.406870126724243e-01}
    ));
}

test "JSON Parse - String, Array, Map -> Requires Allocator" {
    const User = struct { name: []u8, age: u16 };

    const parsed = try std.json.parseFromSlice(
        User,
        test_allocator,
        \\{ "name": "Joe", "age": 25 }
    ,
        .{},
    );
    defer parsed.deinit();

    const user = parsed.value;

    try expect(eql(u8, user.name, "Joe"));
    try expect(user.age == 25);
}

test "JSON Parse - Snippet, String, Array, Map -> Requires Allocator" {
    const User = struct { name: []u8, age: u16, body: [][]u8 };

    const parsed = try std.json.parseFromSlice(
        User,
        test_allocator,
        \\{ "name": "Joe", "age": 25, "body": ["A","B","C"]}
    ,
        .{},
    );
    defer parsed.deinit();

    const user = parsed.value;

    try expect(eql(u8, user.name, "Joe"));
    try expect(user.age == 25);
}

test "Read Line by Line" {
    // Open the file
    //const file = try std.fs.cwd().openFile("/Users/kuro/Library/Application Support/Code/User/snippets/zig.code-snippets", .{});
    const file = try std.fs.cwd().openFile("tests/testfile.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var num_lines: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        _ = line; // autofix

        // print("Line: {s}\n", .{line});
        num_lines += 1;
    }
    //print("{d} lines\n", .{num_lines});

    try expect(num_lines > 0);
}

// "Test Parser": {
//   "prefix": "testparse",
//   "body": [
//     "console.log('$1');",
//     "\tparser(\\$)",
//     "\t\tparser(')",
//     "\nparser(\\)",
//     "parser(\\*)",
//     "parser(\\>)",
//     "parser(/)",
//     "defer std.fs.cwd().deleteFile(\"junk_file.txt\") catch @panic(\"faieled to delete file\");"
//   ],
//   "description": "Log output to console"
// }

// shows up as log Print to Console

// cmd-prefix
// description
// body (commands)
// description (optional) - Descriptive Message for the command

// log creates -> console.log('$cursorhere');

// $ " \
// Above Chars requires extra \ before

// Extra newline as \n
// Tab represented as \t
