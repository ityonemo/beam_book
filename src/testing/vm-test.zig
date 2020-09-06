// ///////////////////////////////////////////////////////////////////
// TESTING

const opcode_t = @import("../operations.zig").opcode_t;

pub fn op(operand: opcode_t) comptime [1]u8 {
    return .{@enumToInt(operand)};
}
pub fn value(integer: u64) comptime [8]u8 {
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
