const std = @import("std");

const print = std.debug.print;
const learn_primitive = @import("learn_primitive");
const number3264 = @import("number3264.zig");
const time = @import("time.zig");
const buffer_bits_demo = @import("buffer_bits_demo.zig");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    print("All your {s} are belong to us.\n", .{"codebase"});

    // > This is appropriate for anything that lives as long as the process.
    // init.arena adalah allocator “sekali pakai selama proses hidup”.
    // Cocok untuk data sementara yang tidak perlu di-free satu-satu.
    const arena: std.mem.Allocator = init.arena.allocator();

    // > Accessing command line arguments:
    // toSlice(arena) mengubah argumen jadi slice array string.
    // Pakai arena karena butuh alokasi memori.
    // try artinya: kalau gagal, error langsung diteruskan ke caller.
    const args = try init.minimal.args.toSlice(arena);
    // Loop for print tiap argumen.
    for (args, 0..) |arg, i| {
        // std.log.info biasanya untuk log (umumnya ke stderr, tergantung konfigurasi log).
        std.log.info(">> args[{d}] = {s} <<", .{ i, arg });
    }

    // args[0] = path executable
    if (args.len < 2) {
        std.log.err("butuh 1 argumen. contoh: zig build run -- halo", .{});
        return;
    }

    const arg1 = args[1];
    std.log.info("arg1: {s}", .{arg1});

    // In order to do I/O operations need an `Io` instance.
    // operasi I/O lewat context Io ini.
    const io = init.io;

    try std.Io.File.stdout().writeStreamingAll(io, "Hello World\n");
    print("Hello, {s}!\n", .{"World 2"});

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    // buffer 1024 byte di stack.
    var stdout_buffer: [1024]u8 = undefined;
    // bikin writer ke stdout dengan buffer itu.
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    // stdout_writer adalah interface writer yang dipakai fungsi lain.
    const stdout_writer = &stdout_file_writer.interface;

    // Memanggil fungsi kamu, kirim writer supaya fungsi bisa menulis ke stdout.
    // Lagi-lagi try untuk propagasi error.
    try learn_primitive.printAnotherMessage(stdout_writer);

    try time.timing(io);

    try number3264.percission();
    buffer_bits_demo.run();

    try stdout_writer.flush(); // Don't forget to flush!
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}
