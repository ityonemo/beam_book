const Vm = @import("../vm.zig").Vm;

pub fn stop_impl(vm: *Vm) void {
    vm.active = false;
}
