const std = @import("std");
const utils = @import("./utils.zig");

const readLine = utils.readLine;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const fmt = std.fmt;
const splitScalar = std.mem.splitScalar;
const AutoListMap = utils.AutoListMap;

const Dot = struct {
    x: u64,
    y: u64,
    z: u64,
};

fn dist2(a: Dot, b: Dot) u64 {
    const dx = if (a.x > b.x) a.x - b.x else b.x - a.x;
    const dy = if (a.y > b.y) a.y - b.y else b.y - a.y;
    const dz = if (a.z > b.z) a.z - b.z else b.z - a.z;
    return dx * dx + dy * dy + dz * dz;
}

const Joint = struct {
    d2: u64,
    a: Dot,
    b: Dot,
};

fn makeJoint(a: Dot, b: Dot) Joint {
    const d2 = dist2(a, b);
    return .{ .d2 = d2, .a = a, .b = b };
}

fn cmpJoints(ctx: void, left: Joint, right: Joint) bool {
    _ = ctx;
    return left.d2 < right.d2;
}

fn cmpIntReverse(ctx: void, left: usize, right: usize) bool {
    _ = ctx;
    return left > right;
}

pub fn Solution() type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        nextGroup: u32,
        group2dot: AutoListMap(u32, Dot),
        dot2group: AutoHashMap(Dot, u32),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .nextGroup = 0,
                .group2dot = AutoListMap(u32, Dot).init(allocator),
                .dot2group = AutoHashMap(Dot, u32).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.group2dot.deinit();
            self.dot2group.deinit();
        }

        pub fn addGroup(self: *Self, gid: u32, a: Dot) !void {
            try self.group2dot.append(gid, a);
            try self.dot2group.put(a, gid);
        }

        pub fn addJoint(self: *Self, a: Dot, b: Dot) !void {
            const ga = self.dot2group.get(a);
            const gb = self.dot2group.get(b);
            if (ga) |g1| {
                if (gb) |g2| {
                    if (g1 != g2) {
                        var list = self.group2dot.map.get(g2).?;
                        for (list.items) |d| {
                            try self.addGroup(g1, d);
                        }
                        _ = self.group2dot.map.remove(g2);
                        list.deinit(self.allocator);
                    }
                } else {
                    try self.addGroup(g1, b);
                }
            } else {
                if (gb) |g2| {
                    try self.addGroup(g2, a);
                } else {
                    try self.addGroup(self.nextGroup, a);
                    try self.addGroup(self.nextGroup, b);
                    self.nextGroup += 1;
                }
            }
        }

        pub fn countGroups(self: *Self) usize {
            return self.group2dot.map.count();
        }

        pub fn countDots(self: *Self) usize {
            return self.dot2group.count();
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var dots = try ArrayList(Dot).initCapacity(allocator, 1000);
    var input: [4096]u8 = undefined;
    while (true) {
        const line = try readLine(&input);
        if (line.len == 0) break;
        var parts = splitScalar(u8, line, ',');
        const x = try fmt.parseInt(u64, parts.next().?, 10);
        const y = try fmt.parseInt(u64, parts.next().?, 10);
        const z = try fmt.parseInt(u64, parts.next().?, 10);
        dots.appendAssumeCapacity(.{ .x = x, .y = y, .z = z });
    }
    const n = dots.items.len;
    const m = n * (n - 1) / 2;
    var joints = try ArrayList(Joint).initCapacity(allocator, m);
    for (dots.items, 0..n) |a, i| {
        for (i + 1..n) |j| {
            const b = dots.items[j];
            const joint = makeJoint(a, b);
            joints.appendAssumeCapacity(joint);
        }
    }
    std.sort.block(Joint, joints.items, {}, cmpJoints);

    var sol = Solution().init(allocator);
    defer sol.deinit();
    const t: u32 = if (n == 20) 10 else 1000;
    for (0..t) |i| {
        const j = joints.items[i];
        try sol.addJoint(j.a, j.b);
    }
    {
        var groups = try ArrayList(usize).initCapacity(allocator, sol.countGroups());
        var it = sol.group2dot.map.valueIterator();
        while (it.next()) |groupDots| {
            groups.appendAssumeCapacity(groupDots.items.len);
        }
        std.sort.block(usize, groups.items, {}, cmpIntReverse);
        print("Part 1: {}\n", .{groups.items[0] * groups.items[1] * groups.items[2]});
    }
    for (t..10000) |i| {
        const j = joints.items[i];
        try sol.addJoint(j.a, j.b);
        if (sol.countDots() == n and sol.countGroups() == 1) {
            print("Part 2: {}\n", .{j.a.x * j.b.x});
            return;
        }
    }
}
