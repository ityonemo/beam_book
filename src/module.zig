//! implements parsing for the .beam file format.  for more information,
//! refer to the documentation here: http://www.erlang.se/~bjorn/beam_file_format.html
//! test modules are generated in the erlang/ directory.

const Mem = @import("std").mem;
const Debug = @import("std").debug;

// chunk parsing dependencies
const Form = @import("module/form.zig");
const AtomTable = @import("module/atom.zig").AtomTable;

pub const ModuleError = error {
    INVALID_CHUNK,
    TOO_SHORT,
    MISMATCHED_SIZE,
};

pub const Module = struct {
    atomtable: ?AtomTable = null,
    expttable: u0 = 0,
    impttable: u0 = 0,
    codetable: u0 = 0,
    strttable: u0 = 0,
    attrtable: u0 = 0,
    cinftable: u0 = 0,
    locttable: u0 = 0,

    // the module object should hold on to its allocator for
    // self-consistency.
    allocator: *Mem.Allocator,

    const chunk_t = enum(u32) {
        ATOM = Mem.bytesToValue(u32, "AtU8"),
        EXPT = Mem.bytesToValue(u32, "ExpT"),
        IMPT = Mem.bytesToValue(u32, "ImpT"),
        CODE = Mem.bytesToValue(u32, "Code"),
        STRT = Mem.bytesToValue(u32, "StrT"),
        ATTR = Mem.bytesToValue(u32, "AttR"),
        CINF = Mem.bytesToValue(u32, "CInf"),
        LOCT = Mem.bytesToValue(u32, "LocT"),
    };

    pub fn from_slice(allocator: *Mem.Allocator, data: []const u8) !Module {
        _ = try Form.validate(data);
        var this_slice = data[12..];
        var module = Module{
            .allocator = allocator,
        };
        //while (this_slice.len >= 0) {
            try parse_slice(&module, &this_slice);
        //}
        return module;
    }

    fn parse_slice(module: *Module, slice: *[]const u8) !void {
        switch (@intToEnum(chunk_t, Mem.bytesToValue(u32, slice.*[0..4]))) {
            .ATOM =>
              module.atomtable = try AtomTable.parse(module.allocator, slice),
            else =>
              unreachable,
        }
    }

    pub fn destroy(module: *Module) void {
        if (module.atomtable) | *table | { AtomTable.destroy(table); }
    }

    pub fn dump(mod: Module) void {}

    /// general helper function used everywhere
    pub fn little_bytes_to_value(src: []const u8) usize {
        var slice = [_]u8{src[3], src[2], src[1], src[0]};
        return Mem.bytesToValue(u32, slice[0..]);
    }
};

