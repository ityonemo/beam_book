const Vm = @import("../vm.zig").Vm;

pub export fn add_impl(vm: *Vm) void {
    Vm.do_push(vm, Vm.do_pop(vm) + Vm.do_pop(vm));
}

// ////////////////////////////////////////////////////////////////////////////
// TESTING

usingnamespace @import("../testing/vm-test.zig");
const assert = @import("std").debug.assert;

test "add does what is expected" {
    comptime const add_operations =
        op(.PUSH) ++
        value(1) ++
        op(.PUSH) ++
        value(2) ++
        op(.ADD);

    var vm = Vm.new();
    var result = try Vm.run(&vm, add_operations[0..]);
    assert(result == 3);
}
