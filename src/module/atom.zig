const Debug = @import("std").debug;
const Mem = @import("std").mem;

const Module = @import("../module.zig").Module;

pub const AtomTable = struct{
    entries: [][]u8 = undefined,
    allocator: *Mem.Allocator,

    const Atom = struct{
        fn parse(allocator: *Mem.Allocator, entry_ptr: *[] u8, slice_ptr: *[] const u8) !void {
            var slice = slice_ptr.*;
            var size: usize = slice[0];
            entry_ptr.* = try allocator.alloc(u8, size);
            Mem.copy(u8, entry_ptr.*, slice[1..]);
            // advance the slice pointer.
            slice_ptr.* = slice[1 + size..];
        }
    };

    pub fn parse(allocator: *Mem.Allocator, slice_ptr: *[] const u8) !AtomTable {
        var slice = slice_ptr.*; // convenience definition

        // does this no-op in release-fast?  double checks that we are in
        // an atom module.
        Debug.assert(Mem.eql(u8, slice[0..4], "AtU8"));

        // first segment is the "total chunk length"
        var chunk_length: usize = Module.little_bytes_to_value(slice[4..8]);
        defer slice_ptr.* = slice[chunk_length..];

        // next segment is the "total number of atoms"
        var atom_count: usize = Module.little_bytes_to_value(slice[8..12]);

        var entries: [][]u8 = try allocator.alloc([]u8, atom_count);

        var atom_slice_ptr = slice[12..];
        for (entries) | *entry | {
            try Atom.parse(allocator, entry, &atom_slice_ptr);
        }

        return AtomTable{.entries = entries, .allocator = allocator};
    }

    pub fn destroy(self: *AtomTable) void {
        for (self.entries) |entry| {self.allocator.free(entry);}
        self.allocator.free(self.entries);
    }
};

// //////////////////////////////////////////////////////////////////////////
// TESTING

const Heap = @import("std").heap;
const test_allocator = @import("std").testing.allocator;
const assert = @import("std").debug.assert;

fn build_atom_header(rest: []const u8) usize {
    Mem.copy(u8, test_mod[0..16], form_with_atom[0..]);
    Mem.copy(u8, test_mod[16..16 + rest.len], rest);
    test_mod[7] = @intCast(u8, rest.len + 8);
    return 16 + rest.len;
}

test "parser works on one atom value" {
    const basic_atom_value = [_]u8{'A', 't', 'U', '8', // utf-8 atoms
                                    0, 0, 0, 16,       // length of this table
                                    0, 0, 0, 1,        // number of atoms
                                    3, 'f', 'o', 'o'}; // atom len + string
    var runtime_zero: usize = 0;
    var slice = basic_atom_value[runtime_zero..];

    var atomtable = try AtomTable.parse(test_allocator, &slice);
    defer AtomTable.destroy(&atomtable);

    // check that atomtable has the the meats.
    assert(atomtable.entries.len == 1);
    assert(Mem.eql(u8, atomtable.entries[0], "foo"));

    // check that the slice has been advanced.
    assert(slice.len == 0);
}


//test "an atom bit is detected" {
//    _ = try Module.from_slice(test_allocator, test_mod[0..bound]);
//}
