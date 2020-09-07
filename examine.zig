/// examines beam files.
const Std = @import("std");
const Debug = Std.debug;
const Os = Std.os;
const Mem = Std.mem;
const Module = @import("src/module.zig").Module;
const read_file = @import("common.zig").read_file;

pub fn main() !u8 {
    // try to read the arguments.
    if (Os.argv.len == 2) {
        // temp the filename
        var filepath = Mem.spanZ(Os.argv[1]);
        // create a master buffer
        var temp_buffer: [1024]u8 = undefined;
        var code_bytes = try read_file(filepath, temp_buffer[0..]);

        var mod = Module.from_slice(temp_buffer[0..code_bytes]);

        return 0;
    } else {
        Debug.warn("needs a file name.\n", .{});
        return 1;
    }
}

// exists to trigger testing across all dependencies.
test "helper" {
    Std.meta.refAllDecls(@This());
}
