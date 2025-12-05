const std = @import("std");

const fmt = std.fmt;
const print = std.debug.print;
const splitScalar = std.mem.splitScalar;
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
  var input: [32]u8 = undefined;
  const Pair = struct {
    x: u64,
    y: u64,
  };
  var ranges = try ArrayList(Pair).initCapacity(arena.allocator(), 200);
  while(true) {
    const result = read_line(&input) catch break;
    if(result.len == 0) {
      break;
    }
    var parts = splitScalar(u8, result, '-');
    const part1 = parts.next().?;
    const part2 = parts.next().?;
    const p1 = fmt.parseInt(u64, part1, 10) catch 0;
    const p2 = fmt.parseInt(u64, part2, 10) catch 0;
    try ranges.append(arena.allocator(), .{ .x = p1, .y = p2 });
  }
  outer: while(true) {
    for (ranges.items, 0..) |a, i| {
      for (ranges.items, 0..) |b, j| {
        if (i == j or a.y < b.x or a.x > b.y) continue;
        if (i < j) {
          _ = ranges.swapRemove(j);
          _ = ranges.swapRemove(i);
        } else {
          _ = ranges.swapRemove(i);
          _ = ranges.swapRemove(j);
        }
        try ranges.append(arena.allocator(), .{ .x = @min(a.x, b.x), .y = @max(a.y, b.y) });
        continue :outer;
      }
    }
    break;
  }
  var r1: u32 = 0;
  while(true) {
    const result = read_line(&input) catch break;
    if (result.len == 0) {
      break;
    }
    const p1 = fmt.parseInt(u64, result, 10) catch 0;
    for (ranges.items) |range| {
      if (p1 >= range.x and p1 <= range.y) {
        r1 += 1;
        break;
      }
    }
  }
  print("Part 1: {d}\n", .{r1});
  var r2: u64 = 0;
  for (ranges.items) |range| {
    r2 += range.y - range.x + 1;
  }
  print("Part 2: {d}\n", .{r2});
}
