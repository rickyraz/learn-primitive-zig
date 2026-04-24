const std = @import("std");

const print = std.debug.print;

pub fn run() void {
    print("\n--- buffer bits demo ---\n", .{});

    // 4-byte buffer with explicit values.
    var buf: [4]u8 = .{ 65, 66, 67, 0 };
    print("buf bytes: {d} {d} {d} {d}\n", .{ buf[0], buf[1], buf[2], buf[3] });

    // Slice is a view into the same buffer (no copy).
    const s: []u8 = buf[0..];
    s[0] = 'Z';
    print("after slice write, buf[0]={c}\n", .{buf[0]});

    // Show binary representation of one byte.
    const b: u8 = 0xA5;
    print("byte b dec={d} hex=0x{x} bin={b}\n", .{ b, b, b });

    // Bit operations: set, clear, toggle.
    var flags: u8 = 0;
    flags |= @as(u8, 1) << 3; // set bit 3
    flags &= ~(@as(u8, 1) << 3); // clear bit 3
    flags ^= @as(u8, 1) << 0; // toggle bit 0
    print("flags={b}\n", .{flags});

    // Endianness when writing multi-byte integers.
    var le: [4]u8 = undefined;
    std.mem.writeInt(u32, &le, 0x11223344, .little);
    print("little-endian: {x} {x} {x} {x}\n", .{ le[0], le[1], le[2], le[3] });
}
