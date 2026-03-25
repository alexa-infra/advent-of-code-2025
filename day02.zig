const std = @import("std");
const utils = @import("./utils.zig");

const fmt = std.fmt;
const print = std.debug.print;
const splitScalar = std.mem.splitScalar;
const readLineUntil = utils.readLineUntil;

pub fn main() !void {
    var input: [32]u8 = undefined;
    var r1: u64 = 0;
    var r2: u64 = 0;
    while (true) {
        const result = try readLineUntil(&input, ',');
        if (result.len == 0) {
            break;
        }
        var parts = splitScalar(u8, result, '-');
        const part1 = parts.next().?;
        const part2 = parts.next().?;

        var buf: [1024]u8 = undefined;
        var slice = buf[0..part1.len];
        std.mem.copyForwards(u8, slice, part1);

        var p1 = try fmt.parseInt(u64, slice, 10);
        const p2 = try fmt.parseInt(u64, part2, 10);

        while (p1 <= p2) {
            const n = slice.len;
            if (n % 2 == 0) {
                const mid = n / 2;
                if (std.mem.eql(u8, slice[0..mid], slice[mid..n])) {
                    r1 += p1;
                }
            }
            for (2..n + 1) |i| {
                if (n % i == 0) {
                    const m = n / i;
                    const first = slice[0..m];
                    var match = true;
                    for (1..i) |j| {
                        const start = j * m;
                        const end = (j + 1) * m;
                        if (!std.mem.eql(u8, first, slice[start..end])) {
                            match = false;
                            break;
                        }
                    }
                    if (match) {
                        r2 += p1;
                        break;
                    }
                }
            }
            for (0..n) |i| {
                const ch = slice[n - 1 - i];
                if (ch == '9') {
                    slice[n - 1 - i] = '0';
                } else {
                    slice[n - 1 - i] = ch + 1;
                    break;
                }
            }
            if (slice[0] == '0') {
                slice = buf[0 .. slice.len + 1];
                slice[0] = '1';
                for (1..slice.len) |i| {
                    slice[i] = '0';
                }
            }
            p1 = try fmt.parseInt(u64, slice, 10);
        }
    }
    print("Part 1: {d}\n", .{r1});
    print("Part 2: {d}\n", .{r2});
}
