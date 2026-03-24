const std = @import("std");
const utils = @import("./utils.zig");

const read_line = utils.read_line;
const parseInt = std.fmt.parseInt;
const splitScalar = std.mem.splitScalar;
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Dot = struct {
    x: u64,
    y: u64,
};

const AreaDot = struct {
    a: u64,
    x: Dot,
    y: Dot,
};

fn cmpAreaDotRev(ctx: void, left: AreaDot, right: AreaDot) bool {
    _ = ctx;
    return left.a > right.a;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var points = ArrayList(Dot).empty;
    var input: [4096]u8 = undefined;
    while (true) {
        const line = try read_line(&input);
        if (line.len == 0) break;
        var parts = splitScalar(u8, line, ',');
        const x = try parseInt(u64, parts.next().?, 10);
        const y = try parseInt(u64, parts.next().?, 10);
        try points.append(allocator, .{ .x = x, .y = y });
    }
    const n = points.items.len;
    const m = n * (n - 1) / 2;
    var areas = try ArrayList(AreaDot).initCapacity(allocator, m);
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const a = points.items[i];
            const b = points.items[j];
            const dx = if (a.x > b.x) a.x - b.x else b.x - a.x;
            const dy = if (a.y > b.y) a.y - b.y else b.y - a.y;
            const area = (dx + 1) * (dy + 1);
            areas.appendAssumeCapacity(.{ .a = area, .x = a, .y = b });
        }
    }
    std.sort.block(AreaDot, areas.items, {}, cmpAreaDotRev);
    print("Part 1: {}\n", .{areas.items[0].a});
    for (areas.items) |it| {
        const a = it.x;
        const b = it.y;
        const minx = if (a.x < b.x) a.x else b.x;
        const miny = if (a.y < b.y) a.y else b.y;
        const maxx = if (a.x > b.x) a.x else b.x;
        const maxy = if (a.y > b.y) a.y else b.y;
        var valid = true;
        for (0..n) |i| {
            const j = (i + 1) % n;
            const c = points.items[i];
            const d = points.items[j];
            const minx1 = if (c.x < d.x) c.x else d.x;
            const miny1 = if (c.y < d.y) c.y else d.y;
            const maxx1 = if (c.x > d.x) c.x else d.x;
            const maxy1 = if (c.y > d.y) c.y else d.y;
            if (!(minx >= maxx1 or maxx <= minx1 or miny >= maxy1 or maxy <= miny1)) {
                valid = false;
                break;
            }
        }
        if (valid) {
            print("Part 2: {}\n", .{it.a});
            break;
        }
    }
}
