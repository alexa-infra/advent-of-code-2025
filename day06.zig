const std = @import("std");
const utils = @import("./utils.zig");

const read_line = utils.read_line;
const tokenizeScalar = std.mem.tokenizeScalar;
const trim = std.mem.trim;
const parseInt = std.fmt.parseInt;
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
  const lastLine = lines.items[lines.items.len - 1];
  for (lastLine, 0..) |ch, i| {
    if (ch == ' ') {
      continue;
    }
    var values = try ArrayList(u64).initCapacity(arena.allocator(), 200);
    for (lines.items[0..lines.items.len - 1]) |line| {
      var it = tokenizeScalar(u8, line[i..], ' ');
      const p = it.next().?;
      const v = parseInt(u64, p, 10) catch 0;
      values.appendAssumeCapacity(v);
    }
    if (ch == '*') {
      var r: u64 = 1;
      for (values.items) |v| {
        r *= v;
      }
      r1 += r;
    } else if (ch == '+') {
      var r: u64 = 0;
      for (values.items) |v| {
        r += v;
      }
      r1 += r;
    }
    values.deinit(arena.allocator());
  }
  print("Part 1: {d}\n", .{r1});
  var r2: u64 = 0;
  for (lastLine, 0..) |ch, i| {
    if (ch == ' ') {
      continue;
    }
    var values = try ArrayList(u64).initCapacity(arena.allocator(), 200);
    for (i..lastLine.len) |j| {
      var col = try ArrayList(u8).initCapacity(arena.allocator(), lines.items.len - 1);
      for (lines.items[0..lines.items.len - 1]) |line| {
        col.appendAssumeCapacity(line[j]);
      }
      const newLine = try col.toOwnedSlice(arena.allocator());
      const newLineTrimmed = trim(u8, newLine, " ");
      if (newLineTrimmed.len == 0) {
        break;
      }
      const v = parseInt(u64, newLineTrimmed, 10) catch 0;
      try values.append(arena.allocator(), v);
    }
    if (ch == '*') {
      var r: u64 = 1;
      for (values.items) |v| {
        r *= v;
      }
      r2 += r;
    } else if (ch == '+') {
      var r: u64 = 0;
      for (values.items) |v| {
        r += v;
      }
      r2 += r;
    }
    values.deinit(arena.allocator());
  }
  print("Part 2: {d}\n", .{r2});
}
