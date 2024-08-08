pub const packages = struct {
    pub const @"1220002d24d73672fe8b1e39717c0671598acc8ec27b8af2e1caf623a4fd0ce0d1bd" = struct {
        pub const build_root = "/Users/kuro/.cache/zig/p/1220002d24d73672fe8b1e39717c0671598acc8ec27b8af2e1caf623a4fd0ce0d1bd";
        pub const build_zig = @import("1220002d24d73672fe8b1e39717c0671598acc8ec27b8af2e1caf623a4fd0ce0d1bd");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "facil.io", "12205e49e9c2c6f0dcab9423fc92d8f0450a4dc2706b68a6d45a448a738ebff70103" },
        };
    };
    pub const @"12205e49e9c2c6f0dcab9423fc92d8f0450a4dc2706b68a6d45a448a738ebff70103" = struct {
        pub const build_root = "/Users/kuro/.cache/zig/p/12205e49e9c2c6f0dcab9423fc92d8f0450a4dc2706b68a6d45a448a738ebff70103";
        pub const build_zig = @import("12205e49e9c2c6f0dcab9423fc92d8f0450a4dc2706b68a6d45a448a738ebff70103");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "clap", "1220002d24d73672fe8b1e39717c0671598acc8ec27b8af2e1caf623a4fd0ce0d1bd" },
};
