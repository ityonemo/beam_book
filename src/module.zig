const Mem = @import("std").mem;
const Debug = @import("std").debug;

// chunk parsing dependencies
const Form = @import("module/form.zig");
const Atom = @import("module/atom.zig");

pub const Module = struct {
    atom: u0 = 0,
    expt: u0 = 0,
    impt: u0 = 0,
    code: u0 = 0,
    strt: u0 = 0,
    attr: u0 = 0,
    cinf: u0 = 0,
    loct: u0 = 0,

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

    pub fn from_slice(data: []const u8) !Module {
        _ = try Form.validate(data);
        var this_slice = data[12..];
        var module = Module{};
        //while (this_slice.len >= 0) {
            parse_slice(&module, &this_slice);
        //}
        return module;
    }

    fn parse_slice(module: *Module, slice: *[]const u8) void {
        switch (@intToEnum(chunk_t, Mem.bytesToValue(u32, slice.*[0..4]))) {
            .ATOM =>
              Atom.parse(),
              //Debug.warn("heyo", .{}),
            else =>
              unreachable,
        }
    }

    pub fn dump(mod: Module) void {}
};
