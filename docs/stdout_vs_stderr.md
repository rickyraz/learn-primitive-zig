# stdout vs stderr (untuk belajar Zig)

Dokumen ini menjelaskan perbedaan `stdout` dan `stderr` dari sisi konsep, sejarah, penggunaan nyata, dan kaitannya dengan memory.

## Ringkasnya

- `stdout` (`fd 1`): output utama program (hasil kerja program).
- `stderr` (`fd 2`): pesan error, warning, debug, diagnosa.

Kalau bingung, pakai aturan ini:
- hasil yang ingin diproses user/pipe -> `stdout`
- pesan masalah/log -> `stderr`

## Kenapa dipisah? (historis singkat)

Di sistem Unix awal, pemisahan ini dibuat supaya:
- output normal bisa dipipe ke program lain
- error tetap terlihat di terminal

Contoh klasik:

```bash
my_program | grep hello
```

Kalau `my_program` mengirim error ke `stdout`, error ikut masuk `grep` dan "mengotori" data.  
Dengan `stderr`, data tetap bersih di pipeline.

## Bedanya dalam praktik shell

File descriptor standar:
- `0` = stdin
- `1` = stdout
- `2` = stderr

Contoh redirection:

```bash
my_program > out.txt        # hanya stdout ke file
my_program 2> err.txt       # hanya stderr ke file
my_program > out.txt 2>&1   # stdout + stderr jadi satu
```

## Di Zig: mana yang dipakai kapan?

### 1) Output utama aplikasi -> stdout

```zig
try std.Io.File.stdout().writeStreamingAll(io, "Hello World\n");
```

Ini cocok untuk output yang ingin di-capture, di-pipe, atau diproses tool lain.

### 2) Debug/diagnostik cepat -> stderr (umumnya)

```zig
std.debug.print("Hello, {s}!\n", .{"World 2"});
```

`std.debug.print` dipakai untuk debug/development output, bukan output data utama aplikasi.

## Kenapa `stdout` write perlu `try`?

Karena operasi I/O bisa gagal. Contoh:
- pipe di ujung lain sudah ditutup (`BrokenPipe`)
- OS error saat write
- handle output tidak valid

Di Zig, fungsi yang bisa gagal mengembalikan `error union`, jadi wajib ditangani (`try`/`catch`/`if`).

## Memory: ini stack atau heap?

Jawaban pendek: bisa campuran, tergantung bagian mana.

### 1) String literal

```zig
"Hello World\n"
```

- ini bukan heap allocation
- biasanya berada di segmen read-only data program (static storage)

### 2) Buffer lokal writer

```zig
var stdout_buffer: [1024]u8 = undefined;
```

- ini variabel lokal -> biasanya di stack frame fungsi
- dipakai untuk buffering user-space sebelum data dikirim ke OS

### 3) Argumen CLI dari `toSlice(arena)`

```zig
const args = try init.minimal.args.toSlice(arena);
```

- ini melakukan alokasi via allocator (`arena`)
- arena allocator biasanya mengambil blok dari allocator bawahnya (seringnya heap / OS pages), lalu membagi-bagi untuk request kecil
- jadi secara praktis: ini memory terkelola allocator, bukan stack biasa

### 4) Buffer kernel untuk fd 1/fd 2

- setelah `write`, data masuk ke layer OS (kernel buffers / device handling)
- ini di luar stack/heap proses kamu

## Buffering: kenapa kadang output urutannya terlihat aneh?

`stdout` sering buffered (line/full buffered tergantung konteks), `stderr` biasanya lebih langsung (sering unbuffered atau line buffered).  
Akibatnya, pesan dari `stdout` dan `stderr` bisa terlihat "tidak urut" di terminal/log tertentu.

Di Zig, kalau pakai writer buffered sendiri, jangan lupa:

```zig
try stdout_writer.flush();
```

Tanpa `flush`, sebagian data bisa masih tertahan di buffer user-space.

## Rule of thumb untuk project CLI

- hasil command (`json`, `text hasil`) -> `stdout`
- error parsing argumen, warning, log internal -> `stderr`
- kalau output adalah bagian dari pipeline, jaga `stdout` tetap bersih dari debug text

## Contoh pola yang rapi

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // Output utama
    try std.Io.File.stdout().writeStreamingAll(io, "result: 42\n");

    // Diagnostik
    std.log.err("example error message", .{});
}
```

## Penutup

Pemisahan `stdout` vs `stderr` itu bukan formalitas; ini fondasi tooling Unix modern: pipeline yang bersih, observability yang jelas, dan error handling yang sehat.
