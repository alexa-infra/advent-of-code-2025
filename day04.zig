const std = @import("std");

const fmt = std.fmt;
const print = std.debug.print;
const ArrayList = std.ArrayList;

fn read_line(buffer: []u8) ![]u8 {
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

pub fn main() !void {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena.deinit();
  var map = try ArrayList([]u8).initCapacity(arena.allocator(), 200);
  var input: [1024]u8 = undefined;
  while(true) {
    const result = read_line(&input) catch break;
    if(result.len == 0) {
      break;
    }
    var row = try ArrayList(u8).initCapacity(arena.allocator(), result.len);
    row.appendSliceAssumeCapacity(result);
    map.appendAssumeCapacity(try row.toOwnedSlice(arena.allocator()));
  }

  const Diff = struct {
    x: isize,
    y: isize,
  };
  var diffs = try ArrayList(Diff).initCapacity(arena.allocator(), 8);
  for (0..3) |dy| {
    for (0..3) |dx| {
      if (dx == 1 and dy == 1) {
        continue;
      }
      try diffs.append(arena.allocator(), .{ .x = @as(isize, @intCast(dx)) - 1, .y = @as(isize, @intCast(dy)) - 1 });
    }
  }

  var r1: u32 = 0;
  const area = map.items;
  const h = area.len;
  const w = area[0].len;
  for (0..h) |y| {
    for (0..w) |x| {
      if (area[y][x] == '@') {
        var count: u8 = 0;
        for (diffs.items) |d| {
          if ((y == 0 and d.y >= 0) or (y > 0 and y < h - 1) or (y == h - 1 and d.y < 1)) {
            if ((x == 0 and d.x >= 0) or (x > 0 and x < w - 1) or (x == w - 1 and d.x < 1)) {
              const y1: isize = @as(isize, @intCast(y)) + d.y;
              const x1: isize = @as(isize, @intCast(x)) + d.x;
              if (area[@intCast(y1)][@intCast(x1)] == '@') {
                count += 1;
              }
            }
          }
        }
        if (count < 4) {
          r1 += 1;
        }
      }
    }
  }
  print("Part 1: {d}\n", .{r1});
  const Pos = struct {
    x: usize,
    y: usize,
  };
  const ArrayPos = ArrayList(Pos);
  var r2: usize = 0;
  while (true) {
    var toRemove = try ArrayPos.initCapacity(arena.allocator(), 200);
    for (0..h) |y| {
      for (0..w) |x| {
        if (area[y][x] == '@') {
          var count: u8 = 0;
          for (diffs.items) |d| {
            if ((y == 0 and d.y >= 0) or (y > 0 and y < h - 1) or (y == h - 1 and d.y < 1)) {
              if ((x == 0 and d.x >= 0) or (x > 0 and x < w - 1) or (x == w - 1 and d.x < 1)) {
                const y1: isize = @as(isize, @intCast(y)) + d.y;
                const x1: isize = @as(isize, @intCast(x)) + d.x;
                if (area[@intCast(y1)][@intCast(x1)] == '@') {
                  count += 1;
                }
              }
            }
          }
          if (count < 4) {
            try toRemove.append(arena.allocator(), .{ .x = x, .y = y });
          }
        }
      }
    }
    if (toRemove.items.len == 0) {
      break;
    }
    r2 += toRemove.items.len;
    for (toRemove.items) |it| {
      area[it.y][it.x] = '.';
    }
    toRemove.deinit(arena.allocator());
  }
  print("Part 2: {d}\n", .{r2});
}
