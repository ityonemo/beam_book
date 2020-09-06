pub const opcode_t = enum(u8) {
    ADD,
    MUL,
    PUSH,
    STOP,
    _
};

const Vm = @import("vm.zig").Vm;

pub export fn add_impl(vm: *Vm) void {
    Vm.do_push(vm, Vm.do_pop(vm) + Vm.do_pop(vm));
}

pub export fn mul_impl(vm: *Vm) void {
    Vm.do_push(vm, Vm.do_pop(vm) * Vm.do_pop(vm));
}

pub export fn push_impl(vm: *Vm) void {
    Vm.do_push(vm, next_8_bytes(vm));
    // advance the instruction by 8 extra slots to account for the
    // 64-bit integer that's just been set into the slot.
    vm.ip += 8;
}

fn next_8_bytes(vm: *const Vm) u64 {
    var bytes_start = vm.ip + 1;
    var ival = .{
        vm.cs[bytes_start],
        vm.cs[bytes_start + 1],
        vm.cs[bytes_start + 2],
        vm.cs[bytes_start + 3],
        vm.cs[bytes_start + 4],
        vm.cs[bytes_start + 5],
        vm.cs[bytes_start + 6],
        vm.cs[bytes_start + 7]
    };
    return @bitCast(u64, ival);
}

const op_t = fn(vm: *Vm) callconv(.C) void;

const operations = [_]op_t{
    add_impl,
    mul_impl,
    push_impl,
};

pub fn dispatch(vm: *Vm) void {
    operations[vm.cs[vm.ip]](vm);
}
