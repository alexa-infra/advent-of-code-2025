const std = @import("std");
const utils = @import("./utils.zig");

const readLine = utils.readLine;
const parseInt = std.fmt.parseInt;
const splitScalar = std.mem.splitScalar;
const print = std.debug.print;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

fn part1(gpa: std.mem.Allocator, line: []u8) !usize {
    var subArena = std.heap.ArenaAllocator.init(gpa);
    defer subArena.deinit();

    const pattern, const buttonToggles, _ = try parseMachine(subArena.allocator(), line);
    const k = pattern.items.len;
    var target = ArrayList(u8).empty;
    try target.appendNTimes(subArena.allocator(), 0, k);
    for (0.., pattern.items) |i, ch| {
        if (ch == '#') {
            target.items[i] = 1;
        }
    }
    const m = buttonToggles.items.len;
    if (m == 0) {
        for (target.items) |it| {
            if (it != 0) {
                unreachable;
            }
        }
        return 0;
    }
    var mat = ArrayList(ArrayList(u8)).empty;
    for (0..k) |_| {
        var row = ArrayList(u8).empty;
        try row.appendNTimes(subArena.allocator(), 0, m + 1);
        try mat.append(subArena.allocator(), row);
    }
    for (0.., buttonToggles.items) |j, idxs| {
        for (idxs.items) |i| {
            mat.items[i].items[j] ^= 1;
        }
    }
    for (0..k) |i| {
        mat.items[i].items[m] = target.items[i];
    }
    var where = ArrayList(usize).empty;
    var whereSet = ArrayList(u8).empty;
    try where.appendNTimes(subArena.allocator(), 0, m);
    try whereSet.appendNTimes(subArena.allocator(), 0, m);
    var xrow: usize = 0;
    var xcol: usize = 0;
    while (xcol < m and xrow < k) {
        var pivot: usize = undefined;
        var pivotFound = false;
        for (xrow..k) |i| {
            if (mat.items[i].items[xcol] != 0) {
                pivot = i;
                pivotFound = true;
                break;
            }
        }
        if (pivotFound) {
            const tmp = mat.items[xrow];
            mat.items[xrow] = mat.items[pivot];
            mat.items[pivot] = tmp;

            where.items[xcol] = xrow;
            whereSet.items[xcol] = 1;
            for (xrow + 1..k) |i| {
                if (mat.items[i].items[xcol] != 0) {
                    for (xcol..m + 1) |j| {
                        mat.items[i].items[j] ^= mat.items[xrow].items[j];
                    }
                }
            }
            xrow += 1;
        }
        xcol += 1;
    }
    for (0..k) |i| {
        var allZero = true;
        for (0..m) |j| {
            if (mat.items[i].items[j] != 0) {
                allZero = false;
                break;
            }
        }
        if (allZero and mat.items[i].items[m] != 0) {
            unreachable;
        }
    }
    for (0..m) |t| {
        const c = m - 1 - t;
        if (whereSet.items[c] == 0) {
            continue;
        }
        const ri = where.items[c];
        for (0..ri) |i| {
            if (mat.items[i].items[c] != 0) {
                for (c..m + 1) |j| {
                    mat.items[i].items[j] ^= mat.items[ri].items[j];
                }
            }
        }
    }
    var freeCols = ArrayList(usize).empty;
    for (0..m) |c| {
        if (whereSet.items[c] == 0) {
            try freeCols.append(subArena.allocator(), c);
        }
    }
    const d = freeCols.items.len;
    if (d > 30) {
        unreachable;
    }
    const limit: usize = @as(u32, 1) << @intCast(d);
    var bestFound = false;
    var best: usize = undefined;
    for (0..limit) |mask| {
        var x = ArrayList(u8).empty;
        try x.appendNTimes(subArena.allocator(), 0, m);
        for (0.., freeCols.items) |i, c| {
            if ((mask >> @intCast(i)) & 1 == 1) {
                x.items[c] = 1;
            }
        }
        for (0..m) |c| {
            if (whereSet.items[c] == 0) {
                continue;
            }
            const ri = where.items[c];
            var v = mat.items[ri].items[m];
            for (freeCols.items) |cc| {
                if (mat.items[ri].items[cc] != 0 and x.items[cc] != 0) {
                    v ^= 1;
                }
            }
            x.items[c] = v;
        }
        var w: usize = 0;
        for (0..m) |j| {
            if (x.items[j] != 0) {
                w += 1;
            }
        }
        if (!bestFound or w < best) {
            best = w;
            bestFound = true;
        }
    }
    if (!bestFound) {
        unreachable;
    }
    return best;
}

const Rat = struct {
    num: i64,
    den: i64,
};

fn gcd(x: i64, y: i64) i64 {
    var a = x;
    var b = y;
    if (a < 0) {
        a = -a;
    }
    if (b < 0) {
        b = -b;
    }
    while (b != 0) {
        const tmp = @mod(a, b);
        a = b;
        b = tmp;
    }
    return if (a != 0) a else 1;
}

fn makeRat(x: i64, y: i64) Rat {
    var num = x;
    var den = y;
    if (num == 0) {
        return Rat{ .num = 0, .den = 1 };
    }
    const t = gcd(num, den);
    num = @divExact(num, t);
    den = @divExact(den, t);
    if (den < 0) {
        num = -num;
        den = -den;
    }
    return Rat{ .num = num, .den = den };
}

fn part2(gpa: std.mem.Allocator, line: []u8) !usize {
    var subArena = std.heap.ArenaAllocator.init(gpa);
    defer subArena.deinit();

    _, const buttonToggles, const targets = try parseMachine(subArena.allocator(), line);
    const k = targets.items.len;
    const m = buttonToggles.items.len;
    var maxTarget: usize = 0;
    for (targets.items) |t| {
        assert(t >= 0);
        if (t > maxTarget) {
            maxTarget = t;
        }
    }
    if (m == 0) {
        for (targets.items) |t| {
            assert(t == 0);
        }
        return 0;
    }
    var signMap = std.AutoHashMap(u16, usize).init(subArena.allocator());
    for (buttonToggles.items) |idxs| {
        if (idxs.items.len == 0) {
            continue;
        }
        var signature: u16 = 0;
        for (idxs.items) |i| {
            signature |= @as(u16, 1) << @intCast(i);
        }
        if (signMap.contains(signature)) {
            const val = signMap.get(signature).?;
            try signMap.put(signature, val + 1);
        } else {
            try signMap.put(signature, 1);
        }
    }
    var uniqSig = std.ArrayList(u16).empty;
    var sigIt = signMap.keyIterator();
    while (sigIt.next()) |sig| {
        try uniqSig.append(subArena.allocator(), sig.*);
    }
    const numSig = uniqSig.items.len;

    var mat = ArrayList(ArrayList(Rat)).empty;
    for (0..k) |_| {
        var row = ArrayList(Rat).empty;
        try row.appendNTimes(subArena.allocator(), makeRat(0, 1), numSig + 1);
        try mat.append(subArena.allocator(), row);
    }
    for (0..k) |i| {
        mat.items[i].items[numSig] = makeRat(targets.items[i], 1);
    }
    for (0.., uniqSig.items) |j, sig| {
        for (0..k) |i| {
            const bit = @as(u16, 1) << @intCast(i);
            if (sig & bit != 0) {
                mat.items[i].items[j] = makeRat(1, 1);
            }
        }
    }

    var pivotCol = ArrayList(usize).empty;
    var pivotColSet = ArrayList(u8).empty;
    try pivotCol.appendNTimes(subArena.allocator(), 0, k);
    try pivotColSet.appendNTimes(subArena.allocator(), 0, k);

    var pivotRow = ArrayList(usize).empty;
    var pivotRowSet = ArrayList(usize).empty;
    try pivotRow.appendNTimes(subArena.allocator(), 0, numSig);
    try pivotRowSet.appendNTimes(subArena.allocator(), 0, numSig);

    var xrow: usize = 0;
    var xcol: usize = 0;
    while (xcol < numSig and xrow < k) {
        var pivotFound = false;
        var pivot: usize = 0;
        for (xrow..k) |i| {
            if (mat.items[i].items[xcol].num != 0) {
                pivot = i;
                pivotFound = true;
                break;
            }
        }
        if (pivotFound) {
            pivotCol.items[xrow] = xcol;
            pivotColSet.items[xrow] = 1;
            pivotRow.items[xcol] = xrow;
            pivotRowSet.items[xcol] = 1;
            const tmp = mat.items[xrow];
            mat.items[xrow] = mat.items[pivot];
            mat.items[pivot] = tmp;
            const pv = mat.items[xrow].items[xcol];
            for (xcol..numSig + 1) |j| {
                const v = mat.items[xrow].items[j];
                mat.items[xrow].items[j] = makeRat(v.num * pv.den, v.den * pv.num);
            }
            for (0..k) |i| {
                if (i == xrow or mat.items[i].items[xcol].num == 0) {
                    continue;
                }
                // mat[i][j] -= mat[i][xcol] * mat[xrow][j]
                const v2 = mat.items[i].items[xcol];
                for (xcol..numSig + 1) |j| {
                    const v = mat.items[i].items[j];
                    const v1 = mat.items[xrow].items[j];
                    const a = v.num;
                    const b = v.den;
                    const c = v2.num;
                    const d = v2.den;
                    const e = v1.num;
                    const f = v1.den;
                    // a/b - c/d * e/f = a/b - ce/df = (adf - bce) / bdf
                    mat.items[i].items[j] = makeRat(a * d * f - b * c * e, b * d * f);
                }
            }
            xrow += 1;
        }
        xcol += 1;
    }
    const numPivotRows = xrow;
    for (0..k) |i| {
        var allZero = true;
        for (0..numSig) |j| {
            if (mat.items[i].items[j].num != 0) {
                allZero = false;
                break;
            }
        }
        if (allZero and mat.items[i].items[numSig].num != 0) {
            unreachable;
        }
    }

    var freeCols = ArrayList(usize).empty;
    for (0..numSig) |c| {
        if (pivotRowSet.items[c] == 0) {
            try freeCols.append(subArena.allocator(), c);
        }
    }
    const numFree = freeCols.items.len;

    var bestFound = false;
    var best: u64 = 0;

    var freeVals = ArrayList(u64).empty;
    try freeVals.appendNTimes(subArena.allocator(), 0, numFree);

    var x = ArrayList(Rat).empty;
    try x.appendNTimes(subArena.allocator(), makeRat(0, 1), numSig);

    while (true) {
        for (0..numSig) |j| {
            x.items[j] = makeRat(0, 1);
        }
        for (0.., freeCols.items) |i, fc| {
            x.items[fc] = makeRat(@intCast(freeVals.items[i]), 1);
        }
        var valid = true;
        for (0..numPivotRows) |r| {
            if (pivotColSet.items[r] == 0) {
                continue;
            }
            const col = pivotCol.items[r];
            var res = mat.items[r].items[numSig];
            for (freeCols.items) |fc| {
                // res -= mat[r][fc] * x[fc]
                const v = mat.items[r].items[fc];
                const v1 = x.items[fc];
                const a = res.num;
                const b = res.den;
                const c = v.num;
                const d = v.den;
                const e = v1.num;
                const f = v1.den;
                // a/b - c/d * e/f
                res = makeRat(a * d * f - b * c * e, b * d * f);
            }
            if (res.den != 1 or res.num < 0) {
                valid = false;
                break;
            }
            x.items[col] = res;
        }
        if (valid) {
            var total: u64 = 0;
            for (x.items) |v| {
                if (v.den != 1 or v.num < 0) {
                    valid = false;
                    break;
                }
                total += @intCast(v.num);
            }
            if (valid and (!bestFound or total < best)) {
                best = total;
                bestFound = true;
            }
        }

        if (numFree == 0) {
            break;
        }

        var pos: usize = numFree - 1;
        var lastPos = false;
        while (pos >= 0) {
            freeVals.items[pos] += 1;
            if (freeVals.items[pos] <= maxTarget) {
                break;
            }
            freeVals.items[pos] = 0;
            if (pos == 0) {
                lastPos = true;
                break;
            }
            pos -= 1;
        }
        if (lastPos) {
            break;
        }
    }

    if (!bestFound) {
        unreachable;
    }
    return best;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var input: [4096]u8 = undefined;
    var lines = ArrayList(ArrayList(u8)).empty;
    while (true) {
        const line = try readLine(&input);
        if (line.len == 0) break;
        var row = ArrayList(u8).empty;
        try row.appendSlice(allocator, line);
        try lines.append(allocator, row);
    }
    var p1: u64 = 0;
    for (lines.items) |line| {
        p1 += try part1(allocator, line.items);
    }
    print("Part 1: {}\n", .{p1});
    var p2: u64 = 0;
    for (lines.items) |line| {
        p2 += try part2(allocator, line.items);
    }
    print("Part 2: {}\n", .{p2});
}

fn parseMachine(allocator: std.mem.Allocator, line: []u8) !struct { ArrayList(u8), ArrayList(ArrayList(u32)), ArrayList(u32) } {
    var pattern = ArrayList(u8).empty;
    var buttonToggles = ArrayList(ArrayList(u32)).empty;
    var targets = ArrayList(u32).empty;

    var parts = splitScalar(u8, line, ' ');
    while (parts.next()) |part| {
        if (part[0] == '[') {
            assert(part[part.len - 1] == ']');
            for (part[1 .. part.len - 1]) |ch| {
                try pattern.append(allocator, ch);
            }
        } else if (part[0] == '(') {
            assert(part[part.len - 1] == ')');
            var subparts = splitScalar(u8, part[1 .. part.len - 1], ',');
            var row = ArrayList(u32).empty;
            while (subparts.next()) |subpart| {
                const ival = try parseInt(u32, subpart, 10);
                try row.append(allocator, ival);
            }
            try buttonToggles.append(allocator, row);
        } else if (part[0] == '{') {
            assert(part[part.len - 1] == '}');
            var subparts = splitScalar(u8, part[1 .. part.len - 1], ',');
            while (subparts.next()) |subpart| {
                const ival = try parseInt(u32, subpart, 10);
                try targets.append(allocator, ival);
            }
        } else {
            unreachable;
        }
    }
    return .{
        pattern,
        buttonToggles,
        targets,
    };
}
