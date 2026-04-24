const std = @import("std");
const print = std.debug.print;

/// A structure for storing a timestamp, with nanosecond precision (this is a
/// multiline doc comment).
const Timestamp = struct {
    /// The number of seconds since the epoch (this is also a doc comment).
    seconds: i64, // signed so we can represent pre-1970 (not a doc comment)
    /// The number of nanoseconds past the second (doc comment again).
    nanos: u32,

    pub fn unixEpoch(io: std.Io) Timestamp {
        const now = std.Io.Timestamp.now(io, .real);
        // total nanodetik sejak epoch disimpan dalam integer signed 96-bit
        const ns: i96 = now.toNanoseconds();
        return Timestamp{
            .seconds = @intCast(@divTrunc(ns, std.time.ns_per_s)),
            // @mod → hasil selalu positif
            .nanos = @intCast(@mod(ns, std.time.ns_per_s)),
        };
    }
};

pub fn timing(io: std.Io) !void {
    // Zig ketat: semua nilai non-void harus dipakai.
    // Timestamp.unixEpoch();
    const ts = Timestamp.unixEpoch(io);
    // std.debug.Info itu bukan fungsi print (di std dia adalah type/simbol lain), jadi compiler bilang: type 'type' not a function.
    // std.debug.Info("ts: {} {d}", .{ ts.seconds, ts.nanos });

    print("ts: {d} {d}\n", .{ ts.seconds, ts.nanos });
    //  logging API
    std.log.info("ts: {d} {d}", .{ ts.seconds, ts.nanos });
}
