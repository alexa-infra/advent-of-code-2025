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

pub fn AutoListMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        map: std.AutoHashMap(K, std.ArrayListUnmanaged(V)),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .map = std.AutoHashMap(K, std.ArrayListUnmanaged(V)).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            var it = self.map.valueIterator();
            while (it.next()) |list| {
                list.deinit(self.allocator);
            }
            self.map.deinit();
        }

        pub fn getOrCreate(self: *Self, key: K) !*std.ArrayListUnmanaged(V) {
            const entry = try self.map.getOrPut(key);

            if (!entry.found_existing) {
                entry.value_ptr.* = .{};
            }

            return entry.value_ptr;
        }

        pub fn append(self: *Self, key: K, value: V) !void {
            var list = try self.getOrCreate(key);
            try list.append(self.allocator, value);
        }
    };
}
