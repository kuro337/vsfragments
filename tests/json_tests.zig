const std = @import("std");
const test_allocator = std.testing.allocator;
const expect = std.testing.expect;
const print = std.debug.print;
const eql = std.mem.eql;

// zig build-exe vector.zig
// ./vector
// zig test file.zig
test "JSON Parse - Snippet, String, Array, Map -> Requires Allocator" {
    const User = struct { name: []u8, age: u16, body: [][]u8 };

    const parsed = try std.json.parseFromSlice(
        User,
        test_allocator,
        \\{ "name": "Joe","age": 25, "body": [
        \\"A","B","C"]}
    ,
        .{},
    );
    defer parsed.deinit();

    const user = parsed.value;

    try expect(eql(u8, user.name, "Joe"));
    try expect(user.age == 25);

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());

    try std.json.stringify(user, .{}, string.writer());

    //print("Stringified {s}\n", .{string.items});

    //  print("parsed {s}", user);
}

test "JSON Parse - String, Array, Map -> Requires Allocator" {

    // ========== DECLARE SHAPE

    const User = struct { name: []u8, age: u16 };

    // ========== PASS STRING

    const s_json = "{ \"name\": \"Joe\", \"age\": 25 \n}";

    const parsed = try std.json.parseFromSlice(
        User,
        test_allocator,
        s_json
        //\\{ "name": "Joe", "age": 25 }
        ,
        .{},
    );

    const user = parsed.value;

    try expect(eql(u8, user.name, "Joe"));
    try expect(user.age == 25);

    //print("\nparsed {s}\n", .{user.name});
    //print("parsed {d}\n", .{user.age});

    // cant print the json directly
    //print("parsed {}\n", .{user});

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());

    try std.json.stringify(user, .{}, string.writer());

    // print("Stringified {s}\n", .{string.items});
    try expect(user.age < 300);
    const string_to_slice_parsed = try string.toOwnedSlice();
    _ = string_to_slice_parsed; // autofix

    //print("Type {s}\n", .{string_to_slice_parsed});

    defer parsed.deinit();

    try expect(true);
}
