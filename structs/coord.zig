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
