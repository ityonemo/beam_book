const Vm = @import("../vm.zig").Vm;

pub export fn push_impl(vm: *Vm) void {
    Vm.do_push(vm, next_8_bytes(vm));
    // advance the instruction by 8 extra slots to account for the
    // 64-bit integer that's just been set into the slot.
    vm.ip += 8;
}

// ////////////////////////////////////////////////////////////////////////////
// TESTING

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

usingnamespace @import("../testing/vm-test.zig");
const Debug = @import("std").debug;
const assert = Debug.assert;

test "push adds a value to the stack" {
    comptime const push_operations = @"op"(.PUSH) ++ @"value"(47);
    var vm = Vm.new();
    var result = try Vm.run(&vm, push_operations[0..]);
    Debug.warn("result {}\n", .{result});
    assert(result == 47);
}
