const std = @import("std");
const utils = @import("./utils.zig");

const fmt = std.fmt;
const print = std.debug.print;
const readLine = utils.readLine;

pub fn main() !void {
  var input: [32]u8 = undefined;
  var pos: u32 = 50;
  var r1: u32 = 0;
  var r2: u32 = 0;
  while(true) {
    const result = try readLine(&input);
    if(result.len == 0) {
      break;
    }
    var val = try fmt.parseInt(u32, result[1..result.len], 10);
    r2 += val / 100;
    val = val % 100;
    if (result[0] == 'L') {
      if (val > pos) {
        if (pos != 0) {
          r2 += 1;
        }
        pos = (pos + 100 - val) % 100;
      } else {
        pos = (pos - val) % 100;
      }
    } else if (result[0] == 'R') {
      if (pos + val > 100) {
        r2 += 1;
      }
      pos = (pos + val) % 100;
    } else {
      print("wrong line: {s}\n", .{result});
      break;
    }
    if (pos == 0) {
      r2 += 1;
      r1 += 1;
    }
  }
  print("Part 1: {d}\n", .{r1});
  print("Part 2: {d}\n", .{r2});
}
