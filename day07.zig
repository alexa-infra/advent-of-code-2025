const std = @import("std");
const utils = @import("./utils.zig");

const read_line = utils.read_line;
const print = std.debug.print;
const ArrayList = std.ArrayList;

pub fn main() !void {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena.deinit();
  var lines = try ArrayList([]u8).initCapacity(arena.allocator(), 200);
  var input: [4096]u8 = undefined;
  while (true) {
    const line = read_line(&input) catch return;
    if (line.len == 0) break;
    var row = try ArrayList(u8).initCapacity(arena.allocator(), line.len);
    row.appendSliceAssumeCapacity(line);
    lines.appendAssumeCapacity(try row.toOwnedSlice(arena.allocator()));
  }
  var r1: u64 = 0;
  const n: usize = lines.items.len;
  const m: usize = lines.items[0].len;
  const state = arena.allocator().alloc(u64, m) catch return;
  @memset(state[0..m], 0);
  var nextState = arena.allocator().alloc(u64, m) catch return;
  for (lines.items, 0..) |line, i| {
    if (i == n - 1) continue;
    @memset(nextState[0..m], 0);
    const nextLine = lines.items[i + 1];
    for (0..m) |j| {
      if (line[j] == 'S') {
        state[j] = 1;
      }
      if (state[j] != 0) {
        if (nextLine[j] == '^') {
          r1 += 1;
          nextState[j - 1] += state[j];
          nextState[j + 1] += state[j];
        } else {
          nextState[j] += state[j];
        }
      }
    }
    std.mem.copyForwards(u64, state, nextState);
  }
  print("Part 1: {d}\n", .{r1});
  var r2: u64= 0;
  for (state) |v| {
    r2 += v;
  }
  print("Part 2: {d}\n", .{r2});
}
