pub const opcode_t = enum(u8) {
    ADD,
    MUL,
    PUSH,
    STOP,
    _
};

const Vm = @import("vm.zig").Vm;

const op_t = fn(vm: *Vm) callconv(.C) void;

// import all of the operations.
usingnamespace @import("operations/add.zig");
usingnamespace @import("operations/mul.zig");
usingnamespace @import("operations/push.zig");

const operations = [_]op_t{
    add_impl,
    mul_impl,
    push_impl,
};

pub fn dispatch(vm: *Vm) void {
    operations[vm.cs[vm.ip]](vm);
}

