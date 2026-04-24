# `*` dan `&` di Zig (dibanding Go)

## Ringkas dulu

- `&x` di Zig: ambil alamat `x` (address-of), hasilnya pointer.
- `*T` di Zig: tipe pointer ke `T`.
- `p.*` di Zig: dereference pointer `p` (akses nilai yang ditunjuk).

Jadi di Zig, dereference **bukan** `*p` seperti Go/C, tapi `p.*`.

## Contoh paling basic

```zig
const std = @import("std");

pub fn main() void {
    var x: i32 = 10;
    const p: *i32 = &x; // pointer ke x

    p.* += 5; // dereference lalu ubah nilai
    std.debug.print("x = {d}\n", .{x}); // 15
}
```

## Makna `*` di Zig

`*` punya beberapa konteks:

- Di tipe: `*T` artinya pointer ke `T`.
- Di ekspresi matematika: perkalian (`a * b`).
- Untuk dereference pointer: pakai `. *` setelah expression pointer (`p.*`).

## Makna `&` di Zig

- `&value` mengambil alamat dari nilai lvalue.
- Hasilnya pointer dengan mutability sesuai asalnya:
  - dari `var` -> biasanya `*T`
  - dari `const` -> biasanya `*const T`

## Apakah sama dengan Go?

Mirip konsep dasarnya, beda detail penting.

### Yang mirip

- Keduanya punya `&` untuk ambil alamat.
- Keduanya punya pointer bertipe (`*T`).
- Keduanya bisa ubah nilai lewat pointer.

### Yang beda penting

1. Sintaks dereference
- Go: `*p`
- Zig: `p.*`

2. Nullability
- Go pointer bisa `nil` secara default.
- Zig pointer biasa `*T` tidak nullable.
- Kalau nullable, Zig pakai optional pointer: `?*T`.

3. Memory model
- Go ada GC.
- Zig tidak ada GC by default; kamu kontrol alokasi/dealokasi sendiri via allocator/ownership.

4. Pointer categories di Zig lebih kaya
- `*T` : single-item pointer
- `[*]T` : many-item pointer (mirip raw pointer ke banyak elemen)
- `[]T` : slice (pointer + length)
- `[*:0]T` : sentinel-terminated pointer (mis. C-style string)

5. Mutability sangat eksplisit
- `*T` vs `*const T`
- Compiler Zig ketat soal mutasi lewat pointer.

## Contoh nullable pointer di Zig

```zig
var x: i32 = 42;
var p: ?*i32 = &x;

if (p) |ptr| {
    ptr.* += 1;
}
```

## Kapan pakai pointer vs slice?

- Pakai `*T` kalau benar-benar satu objek.
- Pakai `[]T` untuk data berurutan karena ada length (lebih aman untuk iterasi/bounds).

## Intuisi praktis

- Kalau dari Go lalu masuk Zig:
  - ganti pola `*p` jadi `p.*`
  - lebih eksplisit soal nullable (`?*T`) dan constness (`*const T`)
  - jangan asumsi GC; pikirkan lifecycle memory lebih awal

## Mental Model Zig (System, Runtime, Language Engineering)

### 1) System Engineering

- Anggap program Zig bernegosiasi langsung dengan kontrak OS/hardware.
- Endianness, alignment, ABI, dan format data adalah bagian desain utama.
- I/O selalu bisa gagal; jalur error bukan opsional.
- Pisahkan channel output:
  - `stdout` untuk data utama (machine-consumable)
  - `stderr/log` untuk diagnosis
- Prioritaskan determinisme dan reproducibility.

### 2) Runtime Engineering

- Tidak ada GC default: lifecycle memory adalah tanggung jawab developer.
- Selalu tahu data hidup di mana:
  - stack
  - allocator/heap
  - arena
  - static storage
- Buffering dan `flush()` mempengaruhi perilaku runtime nyata.
- State global/static bisa membantu, tapi menambah coupling dan risiko race.
- Optimasi setelah benar dan terukur (profiling dulu).

### 3) Language Engineering

- Zig menuntut explicitness:
  - cast eksplisit
  - error handling eksplisit
  - nullability/mutability eksplisit
- Bedakan kontrak tipe pointer:
  - `*T`
  - `?*T`
  - `*const T`
  - `[]T`
- Gunakan `comptime` sebagai alat desain, bukan untuk membuat kode jadi sulit dibaca.
- Type inference ada, tapi tipe API publik sebaiknya tetap tegas.

## Checklist yang Harus Selalu Diingat

1. Siapa pemilik memory ini, dan kapan masa hidupnya berakhir?
2. Kontrak bit/data apa yang dijanjikan ke sistem lain?
3. Error apa saja yang mungkin terjadi, dan sudah ditangani?
4. Output ini untuk mesin (`stdout`) atau untuk observability (`stderr/log`)?
5. Apakah perilaku tetap benar di release build, concurrency, dan platform lain?
