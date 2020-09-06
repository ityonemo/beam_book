const Vm = @import("../vm.zig").Vm;

pub export fn stop_impl(vm: *Vm) void {
    vm.active = false;
}
