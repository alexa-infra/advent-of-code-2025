const std = @import("std");

const fmt = std.fmt;
const print = std.debug.print;

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
  var input: [1024]u8 = undefined;
  var r1: u32 = 0;
  var r2: u64 = 0;
  while(true) {
    const result = read_line(&input) catch break;
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
    r1 += fmt.parseInt(u32, &value, 10) catch 0;

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
    r2 += fmt.parseInt(u64, &val, 10) catch 0;
  }
  print("Part 1: {d}\n", .{r1});
  print("Part 2: {d}\n", .{r2});
}
