const std = @import("std");
const utils = @import("./utils.zig");

const readLine = utils.readLine;
const splitScalar = std.mem.splitScalar;
const splitSequence = std.mem.splitSequence;
const countScalar = std.mem.count;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var input: [4096]u8 = undefined;
    var sizes = std.ArrayList(u32).empty;
    var p1: usize = 0;
    while (true) {
        var line = try readLine(&input);
        if (countScalar(u8, line, "x") == 1) {
            var it1 = splitSequence(u8, line, ": ");
            const part1 = it1.next().?;
            var it2 = splitScalar(u8, part1, 'x');
            const width = try parseInt(u32, it2.next().?, 10);
            const height = try parseInt(u32, it2.next().?, 10);
            const part2 = it1.next().?;
            var it3 = splitScalar(u8, part2, ' ');
            var size: u32 = 0;
            var i: u32 = 0;
            while (it3.next()) |v| {
                const count = try parseInt(u32, v, 10);
                size += count * sizes.items[i];
                i += 1;
            }
            if (size <= width * height) {
                p1 += 1;
            }
        } else if (countScalar(u8, line, ":") == 1) {
            var it1 = splitScalar(u8, line, ':');
            const part1 = it1.next().?;
            _ = try parseInt(u32, part1, 10);
            var size: usize = 0;
            while (true) {
                line = try readLine(&input);
                if (line.len == 0) break;
                size += countScalar(u8, line, ".");
                size += countScalar(u8, line, "#");
            }
            try sizes.append(allocator, @intCast(size));
        } else {
            break;
        }
    }
    print("Part 1: {}\n", .{p1});
}
