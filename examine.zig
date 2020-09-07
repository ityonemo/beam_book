/// examines beam files.
const Std = @import("std");
const Debug = Std.debug;
const Os = Std.os;
const Mem = Std.mem;
const Module = @import("src/module.zig").Module;
const read_file = @import("common.zig").read_file;

// memory allocation
const Heap = @import("std").heap;
const ArenaAllocator = Heap.ArenaAllocator;
const PageAllocator = Heap.page_allocator;

pub fn main() !u8 {
    // set up an arena allocator, for now.
    var arena = ArenaAllocator.init(PageAllocator);
    defer arena.deinit();

    // try to read the arguments.
    if (Os.argv.len == 2) {
        // temp the filename
        var filepath = Mem.spanZ(Os.argv[1]);
        // create a master buffer
        var temp_buffer: [1024]u8 = undefined;
        var code_bytes = try read_file(filepath, temp_buffer[0..]);

        var mod = Module.from_slice(&arena.allocator, temp_buffer[0..code_bytes]);

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
