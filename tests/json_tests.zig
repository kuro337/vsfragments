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

test "JSON Validation Tests" {
    const allocator = std.testing.allocator;
    const stdJson = std.json;

    // Define a struct for test cases
    const TestCase = struct {
        json: []const u8,
        isValid: bool,
    };

    // List of test cases
    const testCases = [_]TestCase{
        TestCase{ .json = "{ \"name\": \"Joe\", \"age\": 25 }", .isValid = true },
        TestCase{ .json = "{\"Zig Print\":{\"name\": \"Joe\", \"age\": 25 }}", .isValid = true },
        TestCase{ .json = "{some: \"invalid JSON\"}", .isValid = false },
        TestCase{ .json = 
        \\ {
        \\"hello" : "world"
        \\}
        , .isValid = true },
        TestCase{ .json = 
        \\ {
        \\'invalid' : 'singlequotes'
        \\}
        , .isValid = false },
        TestCase{ .json = 
        \\ { "VSFragments Title" : {
        \\"hello" : "world"
        \\  }
        \\}
        , .isValid = true },
        TestCase{ .json = 
        \\ { "VSFragments Title" : {
        \\"hello" : "world"
        \\  }
        \\
        , .isValid = false },
        TestCase{ .json = 
        \\{"VSCode Code Snippet": {"prefix": "prefix_insertSnippet","body": ["# Threading OS Threads","","```rust","const std = @import(\"std\");","const expect = std.testing.expect;","const print = std.debug.print;","const ArrayList = std.ArrayList;","const test_allocator = std.testing.allocator;","const eql = std.mem.eql;","const Thread = std.Thread;","","pub fn main() !void {","   \tstd.debug.print(\"{s}\\n\", .{\"Hello, world!\"});","}","```"],"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."}
        \\}
        , .isValid = true },
        TestCase{ .json = 
        \\{"Extra Comma Failure": {"prefix": "prefix_insertSnippet","body": ["# Threading OS Threads","","```rust","```",],"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."}
        \\}
        , .isValid = false },
        TestCase{ .json = 
        \\{"Git Clear Cache": {"prefix": "gitcache","body": ["# Removes files from Git Tree - run git add . after this to Readd all then Commit and Push","git rm --cached -r ."],"description": "Log output to console"},"Git Init Repo - Merge Repo Files to Local and Push Local": {"prefix": "gitinitmergepush","body": ["git init","git add .","git commit -m \"Initial commit for vembed package\"","# To Merge Safely with Existing Files on Main","git pull origin main --allow-unrelated-histories --rebase","git remote add origin https://github.com/kuro337/vembed.git""git push -u origin main"],"description": "When new repo - created with 1 file in main use this to merge with local files and push to remote"}
        \\}
        \\
        \\
        , .isValid = false},
    };

    // Iterate through each test case
    for (testCases) |testCase| {
        const result = try stdJson.validate(allocator, testCase.json);

        try std.testing.expectEqual(testCase.isValid, result);
    }
}

test "Validate File" {
    const allocator = std.testing.allocator;

    const valid_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/validsnippet.json";
    const invalid_file = "/Users/kuro/Documents/Code/Zig/FileIO/vsfragments/tests/mock/invalidsnippet.json";

    const valid_content = try readFile(allocator, valid_file);
    const invalid_content = try readFile(allocator, invalid_file);

    defer {
        allocator.free(invalid_content);
        allocator.free(valid_content);
    }

    const valid_file_result = try std.json.validate(allocator, valid_content);

    try std.testing.expectEqual(true, valid_file_result);

    const invalid_file_result = try std.json.validate(allocator, invalid_content);

    try std.testing.expectEqual(false, invalid_file_result);
}

test "Validate Structure" {
    const valid_structure =
        \\{ "title": {"prefix": "prefix_insertSnippet","body": ["# Threading OS Threads","","```rust","const std = @import(\"std\");","const expect = std.testing.expect;","const print = std.debug.print;","const ArrayList = std.ArrayList;","const test_allocator = std.testing.allocator;","const eql = std.mem.eql;","const Thread = std.Thread;","","pub fn main() !void {","   \tstd.debug.print(\"{s}\\n\", .{\"Hello, world!\"});","}","```"],"description": "Some Useful Snippet Descriptor. Pass --desc <string> to set explicitly."}
        \\}
    ;

    const parsed = try std.json.parseFromSlice(
        Snippet,
        test_allocator,
        valid_structure,
        .{},
    );
    defer parsed.deinit();

    try std.testing.expect(true);
}

pub const Snippet = struct {
    title: Content,
};

pub const Content = struct {
    prefix: []u8,
    body: [][]u8,
    description: []u8,
};

pub fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // Determine the file size
    const fileSize = try file.getEndPos();

    // Allocate a buffer to hold the file content
    const buffer = try allocator.alloc(u8, fileSize);
    // defer allocator.free(buffer);

    // Read the file content into the buffer
    _ = try file.readAll(buffer);

    return buffer;
}
