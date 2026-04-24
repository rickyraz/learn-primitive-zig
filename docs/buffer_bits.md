# Buffer dan Perilaku Bit di Zig 0.16

Dokumen ini untuk memahami:
- apa itu buffer
- bagaimana buffer disimpan di memory
- bagaimana isi buffer direpresentasikan sebagai bit
- praktik aman saat membaca/menulis buffer di Zig 0.16

## 1) Apa itu buffer?

Buffer adalah blok memory berurutan untuk menampung data sementara.

Contoh paling umum:
- `var buf: [1024]u8 = undefined;`

Artinya:
- ada 1024 elemen
- tiap elemen 1 byte (`u8`)
- total kapasitas 1024 byte

## 2) Buffer adalah array byte (dan byte = 8 bit)

`u8` punya range `0..255` dan terdiri dari 8 bit.

Contoh:
- `65` desimal = `0b01000001` = karakter ASCII `'A'`
- `255` desimal = `0b11111111`

Jadi kalau kamu punya:

```zig
var buf: [4]u8 = .{ 65, 66, 67, 0 };
```

Secara byte:
- `buf[0] = 65` (`01000001`)
- `buf[1] = 66` (`01000010`)
- `buf[2] = 67` (`01000011`)
- `buf[3] = 0`  (`00000000`)

## 3) Stack buffer vs allocator buffer

### Stack buffer

```zig
var buf: [1024]u8 = undefined;
```

- cepat
- hidup selama scope fungsi
- ukuran tetap (compile-time known)

### Allocator buffer

```zig
const mem = try allocator.alloc(u8, 1024);
defer allocator.free(mem);
```

- ukuran fleksibel (runtime)
- hidup sampai di-`free`
- cocok untuk data besar/dinamis

## 4) `undefined` artinya apa di buffer?

`undefined` berarti isi awal memory belum ditentukan.  
Jangan dibaca sebelum kamu isi.

Aman:

```zig
var buf: [8]u8 = undefined;
@memset(&buf, 0);
```

atau langsung inisialisasi:

```zig
var buf: [8]u8 = [_]u8{0} ** 8;
```

## 5) Slice: view ke buffer

Di Zig, operasi data biasanya pakai slice:

```zig
const s: []u8 = buf[0..];
```

Slice menyimpan:
- pointer ke data
- length

Jadi slice itu "jendela" ke buffer, bukan copy otomatis.

## 6) Melihat bit dari byte di Zig

Gunakan format binary:

```zig
const std = @import("std");

pub fn main() void {
    const b: u8 = 0xA5; // 165
    std.debug.print("b dec={d} hex=0x{x} bin={b}\n", .{ b, b, b });
}
```

`0xA5` = `10100101`

## 7) Operasi bit pada buffer

Contoh set/clear/toggle bit:

```zig
var b: u8 = 0b00000000;

b |= 1 << 3;  // set bit ke-3 -> 00001000
b &= ~(1 << 3); // clear bit ke-3 -> 00000000
b ^= 1 << 0;  // toggle bit ke-0 -> 00000001
```

Ini sering dipakai untuk flags protocol.

## 8) Packing/Unpacking angka multi-byte

Saat menyimpan integer > 1 byte ke buffer, urutan byte (endianness) penting.

Contoh menulis `u32` ke 4 byte little-endian:

```zig
const std = @import("std");

pub fn main() void {
    var buf: [4]u8 = undefined;
    std.mem.writeInt(u32, &buf, 0x11223344, .little);
    std.debug.print("{x} {x} {x} {x}\n", .{ buf[0], buf[1], buf[2], buf[3] });
    // output byte: 44 33 22 11
}
```

Kalau `.big`, urutannya jadi `11 22 33 44`.

## 9) Buffering di I/O (kenapa perlu flush)

Saat menulis ke file/stdout, sering dipakai buffer user-space dulu:

```zig
var stdout_buffer: [1024]u8 = undefined;
var writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
const w = &writer.interface;
try w.print("hello\n", .{});
try w.flush();
```

Tanpa `flush()`, sebagian byte bisa masih tertahan di buffer.

## 10) Risiko umum saat kerja dengan buffer

- out-of-bounds index (`buf[i]` di luar range)
- membaca `undefined` memory
- lupa `free` untuk allocator buffer
- salah endianness saat protocol/networking
- asumsi string C-style tanpa terminator `0`

## 11) Mini mental model

- Buffer = deretan byte.
- Byte = 8 bit.
- Tipe (`u8`, `u16`, `u32`) menentukan cara interpretasi bit.
- Endianness menentukan urutan byte untuk nilai multi-byte.
- Slice adalah view ke buffer.
- I/O buffer butuh `flush` agar data benar-benar keluar.

Kalau model ini sudah kuat, parsing binary protocol di Zig akan jauh lebih mudah.
