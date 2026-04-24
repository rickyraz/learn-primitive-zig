const std = @import("std");

pub fn tryrefer() !void {
    var x: i32 = 10;
    const p: *i32 = &x; // pointer ke x

    p.* += 5; // dereference lalu ubah nilai
    std.debug.print("x = {d}\n", .{x}); // 15
}
