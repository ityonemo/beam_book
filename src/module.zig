pub const Module = struct {
    form: u0 = 0,
    atom: u0 = 0,
    expt: u0 = 0,
    impt: u0 = 0,
    code: u0 = 0,
    strt: u0 = 0,
    attr: u0 = 0,
    cinf: u0 = 0,
    loct: u0 = 0,

    pub fn from_slice(data: [] const u8) Module {
        return Module{};
    }

    pub fn dump(mod: Module) void {}
};
