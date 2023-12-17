const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    std.debug.print("{s}\n", .{"Hello, world!"});
}

test "Test Printer" {
    const out = std.io.getStdOut();
    var buf = std.io.bufferedWriter(out.writer());
    const w = buf.writer();

    print("{}\n", .{@TypeOf(w)});

    //try w.print("\nPrinted Using the BufferedWriter", .{});

    try buf.flush();

    try std.testing.expect(true);
}

// pub fn Printer(comptime WriterType:type) type {
//     return struct{
//         writer:WriterType,
//         allocator: std.mem.Allocator,

//         pub fn init(writer:WriterType) @This(){ //@This() refers to this inner struct
//             return .{.writer=writer};
//         }
//         //And so forth...
//     };
// }
// zig test printer_tests.zig
