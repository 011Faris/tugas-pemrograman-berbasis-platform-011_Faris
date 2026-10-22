# Perbandingan CSS: Versi Komponen vs Versi Utility-First

## Jumlah Baris CSS / Class Utility

| Metrik | Versi Komponen (CSS) | Versi Utility-First (Tailwind) |
|--------|---------------------|-------------------------------|
| Jumlah baris CSS | 28 baris (di dalam `<style>`) | 0 baris (tidak ada CSS custom) |
| Jumlah class utility | N/A | 12 class utility |

## Detail CSS Versi Komponen
```css
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; background: #f1f5f9; min-height: 100vh; padding: 20px; }
.card { max-width: 360px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 8px 24px rgba(15,23,42,.08); }
.card img { width: 100%; height: 200px; object-fit: cover; border-radius: 8px; margin-bottom: 16px; }
.card h2 { margin: 0 0 4px; font-size: 20px; color: #1e293b; }
.card .nim { margin: 0 0 16px; color: #64748b; font-size: 14px; }
.btn { width: 100%; padding: 12px; border: 0; border-radius: 8px; background: #2563eb; color: #fff; font-weight: 700; font-size: 16px; cursor: pointer; }
.btn:hover { background: #1d4ed8; }
```

## Detail Class Utility Versi Utility-First
```html
<!-- Container utama -->
<div class="mx-auto max-w-sm rounded-xl bg-white p-6 shadow-md">
<!-- mx-auto: margin horizontal auto (center) -->
<!-- max-w-sm: max-width 24rem (384px) -->
<!-- rounded-xl: border-radius 0.75rem (12px) -->
<!-- bg-white: background white -->
<!-- p-6: padding 1.5rem (24px) -->
<!-- shadow-md: box-shadow medium -->

<!-- Gambar -->
<img ... class="w-full h-48 object-cover rounded-lg mb-4">
<!-- w-full: width 100% -->
<!-- h-48: height 12rem (192px) -->
<!-- object-cover: object-fit cover -->
<!-- rounded-lg: border-radius 0.5rem (8px) -->
<!-- mb-4: margin-bottom 1rem (16px) -->

<!-- Judul -->
<h2 class="text-xl font-bold text-slate-900 mb-1">
<!-- text-xl: font-size 1.25rem (20px) -->
<!-- font-bold: font-weight 700 -->
<!-- text-slate-900: text color slate-900 -->
<!-- mb-1: margin-bottom 0.25rem (4px) -->

<!-- NIM -->
<p class="text-sm text-slate-500 mb-4">
<!-- text-sm: font-size 0.875rem (14px) -->
<!-- text-slate-500: text color slate-500 -->
<!-- mb-4: margin-bottom 1rem (16px) -->

<!-- Tombol -->
<button class="w-full rounded-lg bg-blue-600 px-4 py-3 font-semibold text-white hover:bg-blue-700">
<!-- w-full: width 100% -->
<!-- rounded-lg: border-radius 0.5rem (8px) -->
<!-- bg-blue-600: background blue-600 -->
<!-- px-4: padding horizontal 1rem (16px) -->
<!-- py-3: padding vertical 0.75rem (12px) -->
<!-- font-semibold: font-weight 600 -->
<!-- text-white: text color white -->
<!-- hover:bg-blue-700: hover background blue-700 -->
```

## Perbandingan Waktu Pengerjaan

| Aspek | Versi Komponen | Versi Utility-First |
|-------|---------------|---------------------|
| Waktu penulisan awal | ~5 menit | ~3 menit |
| Waktu ubah warna kartu | ~10 detik (ubah 1 selector `.card`) | ~5 detik (ubah 1 class `bg-white` → `bg-slate-50`) |
| Waktu ubah warna tombol | ~10 detik (ubah `.btn` dan `.btn:hover`) | ~5 detik (ubah `bg-blue-600` → `bg-emerald-600` dan `hover:bg-blue-700` → `hover:bg-emerald-700`) |

## Kemudahan Perubahan Tema

**Versi Komponen**: Lebih mudah ketika ada **banyak kartu yang menggunakan class yang sama** (misalnya 10 kartu `.card` di halaman yang berbeda). Cukup ubah CSS di satu tempat, semua kartu berubah.

**Versi Utility-First**: Lebih mudah untuk **perubahan cepat pada satu elemen** atau eksperimen desain. Tidak perlu berpindah file HTML ↔ CSS. Namun, jika ada 10 kartu yang harus diubah warnanya, harus mengedit 10 tempat (kecuali dibungkus jadi komponen Svelte/React/Vue).

## Keputusan untuk Proyek Akhir

| Jenis Halaman | Pendekatan Dipilih | Alasan |
|---------------|-------------------|--------|
| Halaman administrasi (tabel data, formulir CRUD, dashboard internal) | **Component-based (Bootstrap/DaisyUI)** | Pengembangan cepat, konsistensi otomatis, komponen siap pakai (modal, table, form) |
| Halaman publik (landing page, profil, halaman marketing) | **Utility-first (Tailwind CSS)** | Fleksibilitas desain penuh, identitas visual unik, kontrol per properti |
| Komponen yang dipakai berulang (Card, Button, Input) | **Komponen Svelte yang membungkus Tailwind** | Best of both worlds: utility untuk styling, komponen untuk reusabilitas |

**Kesimpulan**: Saya akan menggunakan **pendekatan hybrid** — Tailwind CSS sebagai fondasi utility, dengan DaisyUI/Flowbite untuk komponen admin, dan komponen Svelte kustom (seperti `CardComponent.svelte` dan `CardUtility.svelte` di Pertemuan 3) untuk UI yang dipakai berulang di halaman publik.