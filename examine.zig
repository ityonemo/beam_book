/// examines beam files.
const Std = @import("std");
const Debug = Std.debug;
const Os = Std.os;
const Mem = Std.mem;
const read_file = @import("common.zig").read_file;

pub fn main() !u8 {
    // try to read the arguments.
    if (Os.argv.len == 2) {
        // temp the filename
        var filepath = Mem.spanZ(Os.argv[1]);
        // create a master buffer
        var temp_buffer: [100]u8 = undefined;
        var code_bytes = try read_file(filepath, temp_buffer[0..]);

        return 0;
    } else {
        Debug.warn("needs a file name.\n", .{});
        return 1;
    }
}
