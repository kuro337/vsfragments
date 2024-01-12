const timestamp = @This();

const std = @import("std");
const string = []const u8;
const time = @import("time.zig");

pub fn getTimestampString(allocator: std.mem.Allocator) ![]const u8 {
    const instant = time.DateTime.now();
    const fmt = "YYYY-MM-DD HH:mm:ss";
    const formattedDateTime = try instant.formatAlloc(allocator, fmt);

    return formattedDateTime;
}

test "Simple Time Print" {
    std.log.info("All your codebase are belong to us.", .{});

    const alloc = std.heap.page_allocator;
    const instant = time.DateTime.now();
    const fmt = "YYYY-MM-DD HH:mm:ss";
    const formattedDateTime = try instant.formatAlloc(alloc, fmt);
    defer alloc.free(formattedDateTime);

    std.log.info("Formatted Date and Time: {s}", .{formattedDateTime});
}

// credit to nektro - https://github.com/nektro/zig-time/tree/master Meghan Denny

fn harness(comptime seed: u64, comptime expects: []const [2]string) void {
    for (0..expects.len) |i| {
        _ = Case(seed, expects[i][0], expects[i][1]);
    }
}

fn Case(comptime seed: u64, comptime fmt: string, comptime expected: string) type {
    return struct {
        test {
            const alloc = std.testing.allocator;
            const instant = time.DateTime.initUnixMs(seed);
            const actual = try instant.formatAlloc(alloc, fmt);
            defer alloc.free(actual);
            std.testing.expectEqualStrings(expected, actual) catch return error.SkipZigTest;
        }
    };
}

comptime {
    harness(0, &.{.{ "YYYY-MM-DD HH:mm:ss", "1970-01-01 00:00:00" }});
    harness(1257894000000, &.{.{ "YYYY-MM-DD HH:mm:ss", "2009-11-10 23:00:00" }});
    harness(1634858430000, &.{.{ "YYYY-MM-DD HH:mm:ss", "2021-10-21 23:20:30" }});
    harness(1634858430023, &.{.{ "YYYY-MM-DD HH:mm:ss.SSS", "2021-10-21 23:20:30.023" }});
    harness(1144509852789, &.{.{ "YYYY-MM-DD HH:mm:ss.SSS", "2006-04-08 15:24:12.789" }});

    harness(1635033600000, &.{
        .{ "H", "0" },  .{ "HH", "00" },
        .{ "h", "12" }, .{ "hh", "12" },
        .{ "k", "24" }, .{ "kk", "24" },
    });

    harness(1635037200000, &.{
        .{ "H", "1" }, .{ "HH", "01" },
        .{ "h", "1" }, .{ "hh", "01" },
        .{ "k", "1" }, .{ "kk", "01" },
    });

    harness(1635076800000, &.{
        .{ "H", "12" }, .{ "HH", "12" },
        .{ "h", "12" }, .{ "hh", "12" },
        .{ "k", "12" }, .{ "kk", "12" },
    });
    harness(1635080400000, &.{
        .{ "H", "13" }, .{ "HH", "13" },
        .{ "h", "1" },  .{ "hh", "01" },
        .{ "k", "13" }, .{ "kk", "13" },
    });

    harness(1144509852789, &.{
        .{ "M", "4" },
        .{ "Mo", "4th" },
        .{ "MM", "04" },
        .{ "MMM", "Apr" },
        .{ "MMMM", "April" },

        .{ "Q", "2" },
        .{ "Qo", "2nd" },

        .{ "D", "8" },
        .{ "Do", "8th" },
        .{ "DD", "08" },

        .{ "DDD", "98" },
        .{ "DDDo", "98th" },
        .{ "DDDD", "098" },

        .{ "d", "6" },
        .{ "do", "6th" },
        .{ "dd", "Sa" },
        .{ "ddd", "Sat" },
        .{ "dddd", "Saturday" },
        .{ "e", "6" },
        .{ "E", "7" },

        .{ "w", "14" },
        .{ "wo", "14th" },
        .{ "ww", "14" },

        .{ "Y", "12006" },
        .{ "YY", "06" },
        .{ "YYY", "2006" },
        .{ "YYYY", "2006" },

        .{ "N", "AD" },
        .{ "NN", "Anno Domini" },

        .{ "A", "PM" },
        .{ "a", "pm" },

        .{ "H", "15" },
        .{ "HH", "15" },
        .{ "h", "3" },
        .{ "hh", "03" },
        .{ "k", "15" },
        .{ "kk", "15" },

        .{ "m", "24" },
        .{ "mm", "24" },

        .{ "s", "12" },
        .{ "ss", "12" },

        .{ "S", "7" },
        .{ "SS", "78" },
        .{ "SSS", "789" },

        .{ "z", "UTC" },
        .{ "Z", "+00:00" },
        .{ "ZZ", "+0000" },

        .{ "x", "1144509852789" },
        .{ "X", "1144509852" },
    });

    // https://github.com/nektro/zig-time/issues/3
    harness(1144509852789, &.{.{ "YYYYMM", "200604" }});
}
