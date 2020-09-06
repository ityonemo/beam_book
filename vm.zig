const Mem = @import("std").mem;
const Debug = @import("std").debug;
const Ops = @import("operations.zig");

const opcode_t = Ops.opcode_t;

pub const Vm = struct{
    stack: [1000]u64 = undefined,
    sp: usize = 0,
    ip: usize = 0,
    cs: []const u8 = undefined,

    pub fn new() Vm {
        // fill the stack with zeros
        return Vm{.stack = Mem.zeroes([1000]u64)};
    }

    pub fn run(self: *Vm, code: []const u8) !u64 {
        self.cs = code;
        while (self.ip < code.len) {
            Ops.dispatch(self);
            self.ip += 1;
        }
        return do_pop(self);
    }

    // OPCODE IMPLEMENTATIONS

    // pushes the next value in the code segment onto the
    // stack.  NB This is different from `do_push` as it expects
    // values that are retrieved off of the instruction stream.

    // HELPER FUNCTIONS FOR OPCODES
    pub fn do_push(self: *Vm, integer : u64) void {
        self.stack[self.sp] = integer;
        self.sp += 1;
    }

    pub fn do_pop(self: *Vm) u64 {
        // decrement the stack pointer
        if (self.sp > 0) {
            self.sp -= 1;
            return stackval(self);
        } else {
            return stackval(self);
        }
    }

    // INTERNAL FUNCTIONS
    fn stackval(self: *Vm) u64 {
        return self.stack[self.sp];
    }
};

// ///////////////////////////////////////////////////////////////////
// TESTING

fn @"op"(operand: opcode_t) comptime [1]u8 {
    return .{@enumToInt(operand)};
}
fn @"value"(integer: u64) comptime [8]u8 {
    return .{
        @intCast(u8, 0xFF & integer),
        @intCast(u8, 0xFF & integer >> 8),
        @intCast(u8, 0xFF & integer >> 16),
        @intCast(u8, 0xFF & integer >> 24),
        @intCast(u8, 0xFF & integer >> 32),
        @intCast(u8, 0xFF & integer >> 40),
        @intCast(u8, 0xFF & integer >> 48),
        @intCast(u8, 0xFF & integer >> 56),
    };
}

const assert = @import("std").debug.assert;

test "push adds a value to the stack" {
    comptime const push_operations = @"op"(.PUSH) ++ @"value"(47);
    var vm = Vm.new();
    var result = try Vm.run(&vm, push_operations[0..]);
    Debug.warn("result {}\n", .{result});
    assert(result == 47);
}

test "add does what is expected" {
    comptime const add_operations =
        @"op"(.PUSH) ++
        @"value"(1) ++
        @"op"(.PUSH) ++
        @"value"(2) ++
        @"op"(.ADD);

    var vm = Vm.new();
    var result = try Vm.run(&vm, add_operations[0..]);
    assert(result == 3);
}

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
