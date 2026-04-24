# Signed vs Unsigned Integer di Zig

Dokumen ini menjelaskan:
- historis kenapa ada signed/unsigned
- bagaimana struktur bit-nya
- nilai minimum/maksimum
- kenapa nilainya bisa sebesar itu

## 1) Historis Singkat

Di awal komputasi, integer negatif direpresentasikan dengan beberapa cara:
- sign-magnitude
- ones' complement
- two's complement

Yang akhirnya jadi standar modern adalah **two's complement** karena:
- operasi aritmetika hardware jadi sederhana
- `0` hanya punya satu representasi
- overflow behavior lebih konsisten di level mesin

Zig mengikuti representasi integer modern ini di platform sekarang.

## 2) Struktur Bit

### Unsigned (`uN`)
- Semua `N` bit dipakai untuk besar nilai.
- Tidak ada bit tanda.
- Rentang:
  - min = `0`
  - max = `2^N - 1`

Contoh `u8` (8 bit):
- biner `00000000` = 0
- biner `11111111` = 255

### Signed (`iN`)
- Tetap `N` bit, tapi nilai ditafsirkan signed (two's complement).
- Bit paling kiri berperan sebagai bit tanda dalam interpretasi.
- Rentang:
  - min = `-(2^(N-1))`
  - max = `2^(N-1) - 1`

Contoh `i8`:
- min = `-128`
- max = `127`

Kenapa max signed "kurang satu" dibanding sisi negatif?
- Karena harus menyisakan satu pola bit untuk `0`.
- Di two's complement, nilai negatif punya satu nilai ekstra (`-2^(N-1)`).

## 3) Nilai Maksimum Umum

- `u8` max = 255
- `u16` max = 65_535
- `u32` max = 4_294_967_295
- `u64` max = 18_446_744_073_709_551_615

- `i8` max = 127, min = -128
- `i16` max = 32_767, min = -32_768
- `i32` max = 2_147_483_647, min = -2_147_483_648
- `i64` max = 9_223_372_036_854_775_807, min = -9_223_372_036_854_775_808

## 4) Keunggulan Zig: Lebar Bit Arbitrary

Zig tidak terbatas ke 8/16/32/64 saja.  
Kamu bisa pakai tipe seperti:
- `u1`, `u7`, `u24`
- `i3`, `i17`, `i96`

Ini berguna untuk:
- protocol parsing
- packed structs
- hemat memory sesuai kebutuhan bit sebenarnya

## 5) Cara Cek Nilai Max/Min di Zig

Gunakan `std.math.maxInt` dan `std.math.minInt`:

```zig
const std = @import("std");

pub fn main() void {
    std.debug.print("u8  max = {d}\n", .{std.math.maxInt(u8)});
    std.debug.print("i8  min = {d}, max = {d}\n", .{
        std.math.minInt(i8),
        std.math.maxInt(i8),
    });
    std.debug.print("i96 min = {d}, max = {d}\n", .{
        std.math.minInt(i96),
        std.math.maxInt(i96),
    });
}
```

## 6) Kapan Pakai Signed vs Unsigned?

- Pakai `iN` kalau nilai bisa negatif (suhu, delta, selisih).
- Pakai `uN` kalau nilai tidak mungkin negatif (ukuran buffer, panjang data, bit flags).

Catatan praktis:
- Banyak API Zig memakai `usize` untuk ukuran/index (itu unsigned).
- Saat konversi signed <-> unsigned, selalu hati-hati dan lakukan cast eksplisit.

## 7) Intuisi Cepat

- Tambah 1 bit -> jumlah kombinasi nilai jadi 2x.
- `uN`: semua kombinasi untuk nilai non-negatif.
- `iN`: kombinasi dibagi dua sisi (negatif dan non-negatif), sehingga max positif jadi lebih kecil.

Itu sebabnya:
- `u8` max 255
- `i8` max 127

karena total pola bit keduanya tetap 256.
