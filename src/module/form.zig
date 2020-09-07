//! code for the "form" segment of the module

const Builtin = @import("std").builtin;
const Debug = @import("std").debug;
const Mem = @import("std").mem;

const Module = @import("../module.zig").Module;
const ModuleError = @import("../module.zig").ModuleError;

const FormError = error{
    INVALID_HEADER,
};

// ////////////////////////////////////////////////////////////////////////////
// API

const prefix = "FOR1";
const suffix = "BEAM";

pub fn validate(binary: []const u8) !usize {
    if (binary.len < 12) return ModuleError.TOO_SHORT;

    var size: usize = switch (Builtin.endian) {
        .Big => Mem.bytesToValue(u32, binary[4..8]),
        .Little => Module.little_bytes_to_value(binary[4..8]),
    };

    if (binary.len != size + 8) return ModuleError.MISMATCHED_SIZE;
    if (! Mem.eql(u8, binary[0..4], prefix[0..4])) return FormError.INVALID_HEADER;
    if (! Mem.eql(u8, binary[8..12], suffix[0..4])) return FormError.INVALID_HEADER;
    return size;
}

fn little_bytes_to_value(src: []const u8) usize {
    var slice = [_]u8{src[3], src[2], src[1], src[0]};
    return Mem.bytesToValue(u32, slice[0..]);
}

// ////////////////////////////////////////////////////////////////////////////
// TESTING

const assert = @import("std").debug.assert;

test "form object parses a form binary" {
    var testbin = [_]u8{'F', 'O', 'R', '1', 0, 0, 0, 4, 'B', 'E', 'A', 'M'};
    assert(4 == try validate(testbin[0..]));
}

test "form with bad prefix is rejected" {
    var testbin = [_]u8{'F', 'O', 'R', 'M', 0, 0, 0, 4, 'B', 'E', 'A', 'M'};
    var bad_result = validate(testbin[0..]) catch | err | switch (err) {
        FormError.INVALID_HEADER => 42,
        else => unreachable,
    };
    assert(bad_result == 42);
}

test "too short object fails" {
    var testbin = [_]u8{'F', 'O', 'R', '1', 0, 0, 0, 4, 'B', 'E', 'A'};
    var bad_result = validate(testbin[0..]) catch | err | switch (err) {
        ModuleError.TOO_SHORT => 42,
        else => unreachable,
    };
    assert(bad_result == 42);
}

test "mismatched size fails" {
    var testbin = [_]u8{'F', 'O', 'R', '1', 0, 0, 0, 5, 'B', 'E', 'A', 'M'};
    var bad_result = validate(testbin[0..]) catch | err | switch (err) {
        ModuleError.MISMATCHED_SIZE => 42,
        else => unreachable,
    };
    assert(bad_result == 42);
}

test "form with bad suffix is rejected" {
    var testbin = [_]u8{'F', 'O', 'R', 'M', 0, 0, 0, 4, 'B', 'E', 'A', 'N'};
    var bad_result = validate(testbin[0..]) catch | err | switch (err) {
        FormError.INVALID_HEADER => 42,
        else => unreachable,
    };
    assert(bad_result == 42);
}
