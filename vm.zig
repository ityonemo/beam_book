const Mem = @import("std").mem;
const Debug = @import("std").debug;

const opcode_t = enum(u8) {
    ADD,
    MUL,
    PUSH,
    STOP,
    _
};

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
            var opcode = code[self.ip];
            switch (@intToEnum(opcode_t, opcode)) {
                .ADD => add_impl(self),
                .MUL => mul_impl(self),
                .PUSH => push_impl(self),
                .STOP => break,
                _ => break,
            }
            // advance the instruction pointer.
            self.ip += 1;
        }
        return do_pop(self);
    }

    // OPCODE IMPLEMENTATIONS

    // pushes the next value in the code segment onto the
    // stack.  NB This is different from `do_push` as it expects
    // values that are retrieved off of the instruction stream.
    fn push_impl(self: *Vm) void {
        do_push(self, next_8_bytes(self));
        // advance the instruction by 8 extra slots to account for the
        // 64-bit integer that's just been set into the slot.
        self.ip += 8;
    }

    fn add_impl(self: *Vm) void {
        do_push(self, do_pop(self) + do_pop(self));
    }
    fn mul_impl(self: *Vm) void {
        do_push(self, do_pop(self) * do_pop(self));
    }

    // INTERNAL HELPER FUNCTIONS
    fn do_push(self: *Vm, integer : u64) void {
        self.stack[self.sp] = integer;
        self.sp += 1;
    }

    fn do_pop(self: *Vm) u64 {
        // decrement the stack pointer
        if (self.sp > 0) {
            self.sp -= 1;
            return stackval(self);
        } else {
            return stackval(self);
        }
    }

    fn stackval(self: *Vm) u64 {
        return self.stack[self.sp];
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
