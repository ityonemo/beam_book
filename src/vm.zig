const Mem = @import("std").mem;
const Debug = @import("std").debug;
const Ops = @import("operations.zig");

const opcode_t = Ops.opcode_t;

pub const Vm = struct{
    stack:  [1000]u64 = undefined,
    sp:     usize = 0,
    ip:     usize = 0,
    cs:     [1000]u64 = undefined,
    active: bool = false,

    pub fn new() Vm {
        // fill the stack with zeros
        return Vm{
            .stack  = Mem.zeroes([1000]u64),
            .cs     = Mem.zeroes([1000]u64),
            .active = true,
        };
    }

    pub fn run(self: *Vm, code: []const u8) !u64 {
        Ops.sequence(self, code);
        while (self.active) {
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

