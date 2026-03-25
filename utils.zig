const std = @import("std");

pub fn readLine(buffer: []u8) ![]u8 {
    const stdin = std.fs.File.stdin();
    var idx: usize = 0;

    while (idx < buffer.len) {
        var byte: [1]u8 = undefined;
        const n = stdin.read(&byte) catch break;
        if (n == 0) break;
        if (byte[0] == '\n') break;
        buffer[idx] = byte[0];
        idx += 1;
    }

    return buffer[0..idx];
}

pub fn readLineUntil(buffer: []u8, symbol: u8) ![]u8 {
    const stdin = std.fs.File.stdin();
    var idx: usize = 0;

    while (idx < buffer.len) {
        var byte: [1]u8 = undefined;
        const n = stdin.read(&byte) catch break;
        if (n == 0) break;
        if (byte[0] == '\n') break;
        if (byte[0] == symbol) break;
        buffer[idx] = byte[0];
        idx += 1;
    }

    return buffer[0..idx];
}
