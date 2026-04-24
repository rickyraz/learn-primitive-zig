# Zig Engineering Mental Model

## System Engineering

- Anggap program Zig bernegosiasi langsung dengan kontrak OS/hardware.
- Endianness, alignment, ABI, dan format data adalah bagian desain utama.
- I/O selalu bisa gagal; jalur error bukan opsional.
- Pisahkan channel output:
  - `stdout` untuk data utama (machine-consumable)
  - `stderr/log` untuk diagnosis
- Prioritaskan determinisme dan reproducibility.

## Runtime Engineering

- Tidak ada GC default: lifecycle memory adalah tanggung jawab developer.
- Selalu tahu data hidup di mana:
  - stack
  - allocator/heap
  - arena
  - static storage
- Buffering dan `flush()` mempengaruhi perilaku runtime nyata.
- State global/static bisa membantu, tapi menambah coupling dan risiko race.
- Optimasi setelah benar dan terukur (profiling dulu).

## Language Engineering

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

## Checklist Harian

1. Siapa pemilik memory ini, dan kapan masa hidupnya berakhir?
2. Kontrak bit/data apa yang dijanjikan ke sistem lain?
3. Error apa saja yang mungkin terjadi, dan sudah ditangani?
4. Output ini untuk mesin (`stdout`) atau untuk observability (`stderr/log`)?
5. Apakah perilaku tetap benar di release build, concurrency, dan platform lain?
