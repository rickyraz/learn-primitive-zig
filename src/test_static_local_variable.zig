const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "static local variable" {
    // Pelajaran utama:
    // `S.x` TIDAK di-reset setiap kali `foo()` dipanggil.
    // Karena `var` di dalam namespace struct bersifat static storage
    // (state hidup sepanjang proses), bukan stack local per-call.
    try expectEqual(1235, foo());
    try expectEqual(1236, foo());

    // Implikasi:
    // 1) Fungsi jadi stateful (bukan pure function).
    // 2) Bisa dipakai sebagai counter/cache sederhana.
    // 3) Test bisa saling mempengaruhi jika berbagi state global/static.
    // 4) Untuk pemakaian multi-thread, pattern ini tidak otomatis thread-safe;
    //    perlu sinkronisasi jika diakses bersamaan.
}

fn foo() i32 {
    const S = struct {
        // Static variable di dalam namespace struct.
        // Nilainya persist antar pemanggilan `foo()`.
        var x: i32 = 1234;
    };
    S.x += 1;
    return S.x;
}
