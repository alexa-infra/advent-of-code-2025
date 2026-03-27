const std = @import("std");
const utils = @import("./utils.zig");

const readLine = utils.readLine;
const splitScalar = std.mem.splitScalar;
const print = std.debug.print;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const AutoListMap = utils.AutoListMap;
const StringHashMap = std.StringHashMap;

fn Solution() type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        nextNameId: u32,
        names: StringHashMap(u32),
        nodes: AutoListMap(u32, u32),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .nextNameId = 0,
                .names = StringHashMap(u32).init(allocator),
                .nodes = AutoListMap(u32, u32).init(allocator),
            };
        }

        pub fn getName(self: *Self, str: []const u8) !u32 {
            const entry = try self.names.getOrPut(str);
            if (entry.found_existing) {
                return entry.value_ptr.*;
            }
            entry.value_ptr.* = self.nextNameId;
            self.nextNameId += 1;
            return entry.value_ptr.*;
        }

        pub fn addNode(self: *Self, name1: []const u8, name2: []const u8) !void {
            const id1 = try self.getName(name1);
            const id2 = try self.getName(name2);
            try self.nodes.append(id1, id2);
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var input: [4096]u8 = undefined;
    var s = Solution().init(allocator);
    while (true) {
        const line = try readLine(&input);
        if (line.len == 0) break;
        var parts = splitScalar(u8, line, ' ');
        const buf = try allocator.alloc(u8, 3);
        @memcpy(buf, parts.next().?[0..3]);
        while (parts.next()) |part| {
            const buf1 = try allocator.alloc(u8, 3);
            @memcpy(buf1, part[0..3]);
            try s.addNode(buf, buf1);
        }
    }
    const p1: usize = try part1(allocator, &s);
    print("Part 1: {}\n", .{p1});
    const p2: usize = try part2(allocator, &s);
    print("Part 2: {}\n", .{p2});
}

fn dfs(map: *NodeMap, current: u32, endId: u32, visited: []bool) !usize {
    if (current == endId) {
        return 1;
    }
    var r: usize = 0;

    visited[current] = true;

    const next = map.get(current).?;
    for (next.items) |nextItem| {
        if (!visited[nextItem]) {
            r += try dfs(map, nextItem, endId, visited);
        }
    }

    visited[current] = false;

    return r;
}

const MyKey = struct {
    current: u32,
    wp1visited: bool,
    wp2visited: bool,
};

const MyKeyContext = struct {
    pub fn hash(self: @This(), key: MyKey) u32 {
        _ = self;

        var hasher = std.hash.Wyhash.init(0);

        std.hash.autoHash(&hasher, key.current);
        std.hash.autoHash(&hasher, key.wp1visited);
        std.hash.autoHash(&hasher, key.wp2visited);

        return @truncate(hasher.final());
    }

    pub fn eql(self: @This(), a: MyKey, b: MyKey, b_size: usize) bool {
        _ = b_size;
        _ = self;

        return a.current == b.current and a.wp1visited == b.wp1visited and a.wp2visited == b.wp2visited;
    }
};

const MyMemo = std.ArrayHashMap(MyKey, usize, MyKeyContext, true);
const NodeMap = std.AutoHashMap(u32, std.ArrayListUnmanaged(u32));

fn memoDfs(map: *NodeMap, current: u32, endId: u32, wp1: u32, wp2: u32, visited: []bool, memo: *MyMemo) !usize {
    const wp1visited = visited[wp1];
    const wp2visited = visited[wp2];

    const key = MyKey{
        .current = current,
        .wp1visited = wp1visited,
        .wp2visited = wp2visited,
    };
    if (memo.contains(key)) {
        return memo.get(key).?;
    }

    var r: usize = 0;

    if (current == endId) {
        if (wp1visited and wp2visited) {
            r += 1;
        }
        try memo.put(key, r);
        return r;
    }

    visited[current] = true;

    const next = map.get(current).?;
    for (next.items) |nextItem| {
        if (!visited[nextItem]) {
            r += try memoDfs(map, nextItem, endId, wp1, wp2, visited, memo);
        }
    }

    visited[current] = false;

    try memo.put(key, r);
    return r;
}

fn part1(gpa: std.mem.Allocator, s: *Solution()) !usize {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();

    const start = try s.getName("you");
    const end = try s.getName("out");

    var visited = std.ArrayList(bool).empty;
    try visited.appendNTimes(allocator, false, s.nextNameId);

    return dfs(&s.nodes.map, start, end, visited.items);
}

fn part2(gpa: std.mem.Allocator, s: *Solution()) !usize {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();

    const start = try s.getName("svr");
    const end = try s.getName("out");
    const wp1 = try s.getName("fft");
    const wp2 = try s.getName("dac");

    var visited = std.ArrayList(bool).empty;
    try visited.appendNTimes(allocator, false, s.nextNameId);

    var memo: MyMemo = .init(allocator);
    return memoDfs(&s.nodes.map, start, end, wp1, wp2, visited.items, &memo);
}
