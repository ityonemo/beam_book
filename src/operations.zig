pub const opcode_t = enum(u8) {
    STOP,
    ADD,
    MUL,
    PUSH,
    _
};

const Vm = @import("vm.zig").Vm;
const Debug = @import("std").debug;

const op_t = fn(*Vm) void;
const data_func_t = fn(*Vm, []const u8, *usize, *usize) void;

// import all of the operations.
usingnamespace @import("operations/stop.zig");
usingnamespace @import("operations/add.zig");
usingnamespace @import("operations/mul.zig");
usingnamespace @import("operations/push.zig");

const operations = [_]op_t{
    stop_impl,
    add_impl,
    mul_impl,
    push_impl,
};

fn data_fn(opcode: opcode_t) ?data_func_t {
  return switch (opcode) {
    .PUSH => push_data,
    else => null,
  };
}

pub fn dispatch(vm: *Vm) void {
    @intToPtr(op_t, vm.cs[vm.ip])(vm);
}

/// this function takes byte packed code and converts it into a fixed-length
/// array of 64-bit integers, some of which might be function pointers, some
/// of which might be data immediates, depending on the demands of the code
/// value.
pub fn sequence(vm: *Vm, code: []const u8) void {
    var code_idx: usize = 0;
    var cs_idx: usize = 0;
    while (code_idx < code.len) {
        resequence(vm, code, &code_idx, &cs_idx);
        // required to increment code position AND code segment position.
        code_idx += 1;
        cs_idx += 1;
    }
    // drop an extra stop in there.
    vm.cs[cs_idx] = @ptrToInt(stop_impl);
}

fn resequence(vm: *Vm, code: []const u8, code_idx: *usize, cs_idx: *usize) void {
    var opcode_int = code[code_idx.*];
    vm.cs[cs_idx.*] = @ptrToInt(operations[opcode_int]);
    const df: ?data_func_t = data_fn(@intToEnum(opcode_t, opcode_int));
    if (df) |func| {
        func(vm, code, code_idx, cs_idx);
    }
}
