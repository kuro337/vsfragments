const std = @import("std");

pub const Ally = struct {
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,
    data: []u8,

    // Set data directly
    pub fn setData(self: *Ally, input: []const u8) !void {
        self.data = try self.allocator.dupe(u8, input);
    }

    // Method to convert to C string
    pub fn toCStr(self: *Ally) [*:0]const u8 {
        return self.data.ptr;
    }

    // Destructor
    pub fn destroy(self: *Ally) void {
        self.allocator.free(self.data);
        self.arena.deinit();
    }
};

