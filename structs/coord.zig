const std = @import("std");

pub const Coord = struct {
    lat: f32,
    long: f32,

    pub fn format(
        coord: Coord,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("Lat:{d}\nLong:{d}", .{ coord.lat, coord.long });
    }
};

pub fn main() !void {
    var c = Coord{ .lat = 100, .long = 200 };

    std.debug.print("{}\n", .{c});

    c.lat = 500;

    std.debug.print("{}\n", .{c});
}
