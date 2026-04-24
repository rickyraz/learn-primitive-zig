const std = @import("std");
const print = std.debug.print;

pub fn percission() !void {
    const one_plus_one: i32 = 1 + 1;
    print("1 + 1 = {}\n", .{one_plus_one});

    // floats
    const seven_div_three: f32 = 7.0 / 3.0;
    print("7.0 / 3.0 = {}\n", .{seven_div_three});

    const one_plus_two: f32 = 0.1 + 0.2;
    print("0.1 + 0.2 = {}\n", .{one_plus_two});
    print("one_plus_two : {d:.20}\n", .{one_plus_two});
    print("one_plus_two as f32 {d:.20}\n", .{@as(f32, one_plus_two)});
    print("one_plus_two as f64 {d:.20}\n", .{@as(f64, one_plus_two)});
    const a = @as(f32, 0.1);
    const b: f32 = @as(f32, 0.2);

    const c = a + b;
    const d = @as(f32, 0.1) + @as(f32, 0.2);

    print("c = {d:.20}\n", .{@as(f64, c)});
    print("d = {d:.20}\n", .{@as(f64, d)});
    print("c bits = 0x{x}\n", .{@as(u32, @bitCast(c))});
    print("d bits = 0x{x}\n", .{@as(u32, @bitCast(d))});

    const x = @as(f64, 0.1) + @as(f64, 0.2);
    print("{d:.17}\n", .{x});
}
