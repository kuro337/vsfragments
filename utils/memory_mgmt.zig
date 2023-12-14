const std = @import("std");

pub fn checkMemoryLeaks(gpa: *std.heap.GeneralPurposeAllocator(.{})) void {
    std.debug.print("{s}\n", .{"Checking Heap Allocations..."});

    const leaks = gpa.detectLeaks();
    if (leaks == true) {
        std.debug.print(" > Leaks Detected: {}\n", .{leaks});
    } else {
        std.debug.print(" > No Leaks Found!\n", .{});
    }
}

// Pass a slice of slices to free each line
pub fn clearSliceMatrixMemory(slice: [][]const u8, allocator: *const std.mem.Allocator) void {
    for (slice) |line| {
        allocator.*.free(line);
    }
    allocator.*.free(slice);
}
