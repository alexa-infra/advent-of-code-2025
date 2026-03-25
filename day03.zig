const std = @import("std");
const utils = @import("./utils.zig");

const fmt = std.fmt;
const print = std.debug.print;
const readLine = utils.readLine;

pub fn main() !void {
  var input: [1024]u8 = undefined;
  var r1: u32 = 0;
  var r2: u64 = 0;
  while(true) {
    const result = try readLine(&input);
    if(result.len == 0) {
      break;
    }
    var value: [2]u8 = undefined;
    value[0] = result[0];
    value[1] = result[1];
    for (1..result.len) |i| {
      if (i < result.len - 1 and result[i] > value[0]) {
        value[0] = result[i];
        value[1] = result[i + 1];
      } else if (result[i] > value[1]) {
        value[1] = result[i];
      }
    }
    r1 += try fmt.parseInt(u32, &value, 10);

    var val: [12]u8 = undefined;
    var start: usize = 0;
    for (0..12) |pos| {
      const end = result.len - (12 - pos) + 1;
      const window = result[start..end];
      var maxCharIdx: usize = 0;
      for (1..window.len) |i| {
        if (window[i] > window[maxCharIdx]) {
          maxCharIdx = i;
        }
      }
      val[pos] = window[maxCharIdx];
      const chosenIdx = start + maxCharIdx;
      start = chosenIdx + 1;
    }
    r2 += try fmt.parseInt(u64, &val, 10);
  }
  print("Part 1: {d}\n", .{r1});
  print("Part 2: {d}\n", .{r2});
}
