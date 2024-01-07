const std = @import("std");

const expect = @import("std").testing.expect;
const mem = @import("std").mem;
const Build = std.Build;
const CompileStep = std.Build.Step.Compile;

const FlagEval = enum(u8) {
    invalid,
    file,
    file_out,
    inline_code,
};

fn returnInvalidFlag() FlagEval {
    return FlagEval.invalid;
}

pub const BuildConfig = struct {
    arch: std.Target.Cpu.Arch,
    os: std.Target.Os.Tag,
};

const targets = [_]BuildConfig{ BuildConfig{
    .arch = std.Target.Cpu.Arch.aarch64,
    .os = std.Target.Os.Tag.macos,
}, BuildConfig{
    .arch = std.Target.Cpu.Arch.x86_64,
    .os = std.Target.Os.Tag.linux,
}, BuildConfig{
    .arch = std.Target.Cpu.Arch.x86_64,
    .os = std.Target.Os.Tag.windows,
} };

test "Getting String Values of Enum Types" {
    for (targets) |t| {
        _ = t; // autofix

        try std.testing.expect(true);
        //        std.debug.print("{s},::{s}\n", .{ @tagName(t.arch), @tagName(t.os) });
    }
}

// NOTE -> For Direct switch assignment - we need to define the type Param Explicitly

test "Direct Switch - VALID" {
    const result: u8 = switch (returnInvalidFlag()) {
        FlagEval.invalid => 0,
        else => 1,
    };
    try std.testing.expect(result == 0);
}

test "Inline Switch - VALID as long as void evaluations" {
    switch (returnInvalidFlag()) {
        FlagEval.invalid => try std.testing.expect(true),
        else => try std.testing.expect(true == false),
    }

    try std.testing.expect(true);
}

// test "Direct Switch - INVALID - need to specify type" {
//     const result = switch (returnInvalidFlag()) {
//         FlagEval.invalid => 0,
//         else => 1,
//     };
//     try std.testing.expect(result == 0);
// }

test "Test FlagEval Switch" {
    const p = FlagEval.invalid;

    const what_is_it = switch (p) {
        FlagEval.invalid => "Invalid Evaluation",
        FlagEval.file => "File Only",
        FlagEval.file_out => "File Output",
        FlagEval.inline_code => "Inline String",
    };

    try std.testing.expect(std.mem.eql(u8, what_is_it, "Invalid Evaluation"));
}

test "Test FlagEval Ordinal Value" {
    try expect(@intFromEnum(FlagEval.invalid) == 0);
    try expect(@intFromEnum(FlagEval.file) == 1);
    try expect(@intFromEnum(FlagEval.file_out) == 2);
    try expect(@intFromEnum(FlagEval.inline_code) == 3);
}

// ============================== ENUM SPEC ==============================

// Declare an enum.
const Type = enum {
    ok,
    not_ok,
};

// Declare a specific enum field.
const c = Type.ok;

// If you want access to the ordinal value of an enum, you
// can specify the tag type.
const Value = enum(u2) {
    zero,
    one,
    two,
};
// Now you can cast between u2 and Value.
// The ordinal value starts from 0, counting up by 1 from the previous member.
test "enum ordinal value" {
    try expect(@intFromEnum(Value.zero) == 0);
    try expect(@intFromEnum(Value.one) == 1);
    try expect(@intFromEnum(Value.two) == 2);
}

// You can override the ordinal value for an enum.
const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
};
test "set enum ordinal value" {
    try expect(@intFromEnum(Value2.hundred) == 100);
    try expect(@intFromEnum(Value2.thousand) == 1000);
    try expect(@intFromEnum(Value2.million) == 1000000);
}

// You can also override only some values.
const Value3 = enum(u4) {
    a,
    b = 8,
    c,
    d = 4,
    e,
};
test "enum implicit ordinal values and overridden values" {
    try expect(@intFromEnum(Value3.a) == 0);
    try expect(@intFromEnum(Value3.b) == 8);
    try expect(@intFromEnum(Value3.c) == 9);
    try expect(@intFromEnum(Value3.d) == 4);
    try expect(@intFromEnum(Value3.e) == 5);
}

// Enums can have methods, the same as structs and unions.
// Enum methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,

    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

test "enum method" {
    const p = Suit.spades;
    try expect(!p.isClubs());
}

// An enum can be switched upon.
const Foo = enum {
    string,
    number,
    none,
};
test "enum switch" {
    const p = Foo.number;
    const what_is_it = switch (p) {
        Foo.string => "this is a string",
        Foo.number => "this is a number",
        Foo.none => "this is a none",
    };
    try expect(mem.eql(u8, what_is_it, "this is a number"));
}

// @typeInfo can be used to access the integer tag type of an enum.
const Small = enum {
    one,
    two,
    three,
    four,
};
test "std.meta.Tag" {
    try expect(@typeInfo(Small).Enum.tag_type == u2);
}

// @typeInfo tells us the field count and the fields names:
test "@typeInfo" {
    try expect(@typeInfo(Small).Enum.fields.len == 4);
    try expect(mem.eql(u8, @typeInfo(Small).Enum.fields[1].name, "two"));
}

// @tagName gives a [:0]const u8 representation of an enum value:
test "@tagName" {
    try expect(mem.eql(u8, @tagName(Small.three), "three"));
}
