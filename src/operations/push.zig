const Vm = @import("../vm.zig").Vm;

pub export fn push_impl(vm: *Vm) void {
    Vm.do_push(vm, vm.cs[vm.ip + 1]);
    // advance the instruction by one 64-bit slot
    vm.ip += 1;
}

pub fn push_data(vm: *Vm, code: []const u8, code_idx: *usize, cs_idx: *usize) void {
    // take the next 8 bytes, convert to u64, then put it in the next slot
    // of the code segment.
    vm.cs[cs_idx.* + 1] = next_8_bytes(code, code_idx.* + 1);
    // advance the index of our code, and the index of our code segment.
    code_idx.* += 8;
    cs_idx.* += 1;
}

// ////////////////////////////////////////////////////////////////////////////
// TESTING

fn next_8_bytes(code: []const u8, start: usize) u64 {
    var ival = .{
        code[start],
        code[start + 1],
        code[start + 2],
        code[start + 3],
        code[start + 4],
        code[start + 5],
        code[start + 6],
        code[start + 7]
    };
    return @bitCast(u64, ival);
}

usingnamespace @import("../testing/vm-test.zig");
const Debug = @import("std").debug;
const assert = Debug.assert;

test "push adds a value to the stack" {
    comptime const push_operations = @"op"(.PUSH) ++ @"value"(47);
    var vm = Vm.new();
    var result = try Vm.run(&vm, push_operations[0..]);
    assert(result == 47);
}
