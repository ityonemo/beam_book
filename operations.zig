pub const opcode_t = enum(u8) {
    ADD,
    MUL,
    PUSH,
    STOP,
    _
};

const Vm = @import("vm.zig").Vm;

pub export fn add_impl(self: *Vm) void {
    Vm.do_push(self, Vm.do_pop(self) + Vm.do_pop(self));
}

pub export fn mul_impl(self: *Vm) void {
    Vm.do_push(self, Vm.do_pop(self) * Vm.do_pop(self));
}

pub export fn push_impl(self: *Vm) void {
    Vm.do_push(self, next_8_bytes(self));
    // advance the instruction by 8 extra slots to account for the
    // 64-bit integer that's just been set into the slot.
    self.ip += 8;
}

fn next_8_bytes(self: *const Vm) u64 {
    var bytes_start = self.ip + 1;
    var ival = .{
        self.cs[bytes_start],
        self.cs[bytes_start + 1],
        self.cs[bytes_start + 2],
        self.cs[bytes_start + 3],
        self.cs[bytes_start + 4],
        self.cs[bytes_start + 5],
        self.cs[bytes_start + 6],
        self.cs[bytes_start + 7]
    };
    return @bitCast(u64, ival);
}
