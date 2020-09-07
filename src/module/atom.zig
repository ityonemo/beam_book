const Debug = @import("std").debug;
const Mem = @import("std").mem;

const Module = @import("../module.zig").Module;

pub const Atom = struct{
};

pub fn parse() void {
}

// //////////////////////////////////////////////////////////////////////////
// TESTING

const atom_chunk_header =
  [_]u8{'F', 'O', 'R', '1', 0, 0, 0, 0, 'B', 'E', 'A', 'M', 'A', 't', 'U', '8'};

var test_mod = Mem.zeroes([100]u8);

fn build_atom_chunk(rest: []const u8) usize {
    Mem.copy(u8, test_mod[0..16], atom_chunk_header[0..]);
    Mem.copy(u8, test_mod[16..16 + rest.len], rest);
    test_mod[7] = @intCast(u8, rest.len + 8);
    return 16 + rest.len;
}

test "an atom bit is detected" {
    var bound = build_atom_chunk("");
    _ = try Module.from_slice(test_mod[0..bound]);
}
