const Fs = @import("std").fs;
const File = Fs.File;

pub fn read_file(path: [] const u8, into: []u8) !usize {
    var file = try Fs.cwd().openFile(path, .{});
    defer File.close(file);

    var read_bytes = try File.readAll(file, into[0..]);
    var file_slice = into[0..(read_bytes - 1)];
    return read_bytes;
}
