const Std = @import("std");
const Os = Std.os;
const Fs = Std.fs;
const Mem = Std.mem;
const File = Fs.File;
const Debug = Std.debug;
const Vm = @import("src/vm.zig").Vm;

fn read_file(path: [] const u8, into: []u8) !usize {
    var file = try Fs.cwd().openFile(path, .{});
    defer File.close(file);

    var read_bytes = try File.readAll(file, into[0..]);
    var file_slice = into[0..(read_bytes - 1)];
    return read_bytes;
}

pub fn main() !u8 {
    // try to read the arguments.
    if (Os.argv.len == 2) {
        // temp the filename
        var filepath = Mem.spanZ(Os.argv[1]);
        // create a master buffer
        var temp_buffer: [100]u8 = undefined;
        var code_bytes = try read_file(filepath, temp_buffer[0..]);

        var vm = Vm.new();
        var res = try Vm.run(&vm, temp_buffer[0..code_bytes]);
        Debug.warn("result: {}\n", .{res});

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
