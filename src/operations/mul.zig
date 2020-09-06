const Vm = @import("../vm.zig").Vm;

pub fn mul_impl(vm: *Vm) void {
    Vm.do_push(vm, Vm.do_pop(vm) * Vm.do_pop(vm));
}

// ////////////////////////////////////////////////////////////////////////////
// TESTING

usingnamespace @import("../testing/vm-test.zig");
const assert = @import("std").debug.assert;

test "mul does what is expected" {
    comptime const add_operations =
        @"op"(.PUSH) ++
        @"value"(47) ++
        @"op"(.PUSH) ++
        @"value"(47) ++
        @"op"(.MUL);

    var vm = Vm.new();
    var result = try Vm.run(&vm, add_operations[0..]);
    assert(result == 2209);
}
