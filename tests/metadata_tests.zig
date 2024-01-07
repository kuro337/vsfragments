const std = @import("std");
const TypeInfo = std.meta.TypeInfo;

const Metadata = struct {
    title: []const u8 = "",
    prefix: []const u8 = "",
    description: []const u8 = "",
    create_flag: bool = false,
    force: bool = false,
    input_file: []const u8 = "",
    output_file: []const u8 = "",
};

// usage:
// containsUnsetValues(Metadata, testCase.metadata)
// Checks Fields at Runtime based on the Type

pub fn containsUnsetValues(comptime T: type, value: T) bool {
    inline for (@typeInfo(T).Struct.fields) |field| {
        if (field.type == []const u8) {
            const str = @field(value, field.name);
            if (str.len == 0)
                return true; // std.debug.print("{s} unset\n", .{field.name});
        }
        if (field.type == bool) {
            const b = @field(value, field.name);
            if (b == false)
                return true; // std.debug.print("{s} unset\n", .{field.name});
        }
        //  std.debug.print("{s} SET!\n", .{field.name});
    }
    return false;
}

test "Dynamic Runtime Test" {
    const TableTest = struct {
        metadata: Metadata,
        expected: bool,
    };

    const metadataTestCases = [_]TableTest{
        .{
            .metadata = Metadata{ .title = "Missing Fields", .create_flag = true },
            .expected = true,
        },
        .{
            .metadata = Metadata{},
            .expected = true,
        },
        .{
            .metadata = Metadata{
                .title = "All Fields set but One set Empty",
                .prefix = "",
                .description = "This is a description.",
                .create_flag = true,
                .force = true,
                .input_file = "input.txt",
                .output_file = "output.txt",
            },
            .expected = true,
        },
        .{
            .metadata = Metadata{
                .title = "All Fields set but One set Empty",
                .prefix = "",
                .description = "This is a description.",
                .create_flag = false,
                .force = true,
                .input_file = "input.txt",
                .output_file = "output.txt",
            },
            .expected = true,
        },
        .{
            .metadata = Metadata{
                .title = "All Fields Correctly Set",
                .prefix = "Prefix Value",
                .description = "This is a description.",
                .create_flag = true,
                .force = true,
                .input_file = "input.txt",
                .output_file = "output.txt",
            },
            .expected = false,
        },
    };

    for (metadataTestCases) |testCase| {
        const result = containsUnsetValues(Metadata, testCase.metadata);
        try std.testing.expectEqual(testCase.expected, result);
    }
}

// test "Standard Config Struct with Default Values" {
//     const m = Metadata{ .title = "Some Title", .create_flag = true };
//     compileTimeFunction(Metadata, m);
// }

pub fn compileTimeFunction(comptime T: type, value: T) void {
    inline for (@typeInfo(T).Struct.fields) |field| {
        @compileLog(field.name, @field(value, field.name)); // Print field name and value
    }
}
