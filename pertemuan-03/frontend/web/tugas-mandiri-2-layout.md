# Tugas Mandiri 2 — Layout dengan Class Utility

## Class Utama per Bagian

### 1. Navbar
```html
<nav class="bg-white shadow-sm sticky top-0 z-50">
  <div class="mx-auto max-w-6xl px-4">
    <div class="flex h-16 items-center justify-between">
```
| Class | Fungsi |
|-------|--------|
| `bg-white` | Background putih |
| `shadow-sm` | Bayangan halus di bawah navbar |
| `sticky top-0` | Menempel di atas saat scroll |
| `z-50` | Z-index tinggi agar di atas konten lain |
| `mx-auto max-w-6xl px-4` | Container tengah, max-width 6xl, padding horizontal |
| `flex h-16 items-center justify-between` | Flexbox, tinggi 16 (64px), vertikal center, horizontal space-between |
| `text-xl font-bold text-slate-900` | Judul besar, tebal, warna gelap |
| `gap-6` | Jarak 1.5rem antar tautan nav |
| `hover:text-slate-900 transition-colors` | Efek hover smooth pada tautan |

### 2. Hero Section
```html
<section class="bg-gradient-to-br from-blue-600 to-indigo-700 text-white">
  <div class="mx-auto max-w-6xl px-4 py-20">
    <div class="text-center">
```
| Class | Fungsi |
|-------|--------|
| `bg-gradient-to-br from-blue-600 to-indigo-700` | Gradient diagonal biru ke ungu |
| `text-white` | Teks putih untuk semua anak |
| `py-20` | Padding vertikal 5rem (80px) |
| `text-center` | Teks rata tengah |
| `text-4xl md:text-5xl` | Ukuran font responsif: 4xl di mobile, 5xl di md+ |
| `max-w-2xl mx-auto` | Lebar maksimal paragraf, tengah |

### 3. Three Cards (Grid)
```html
<div class="grid grid-cols-1 gap-6 md:grid-cols-3">
```
| Class | Fungsi |
|-------|--------|
| `grid` | Mengaktifkan CSS Grid |
| `grid-cols-1` | **Default (mobile): 1 kolom** |
| `md:grid-cols-3` | **Di breakpoint md (≥768px): 3 kolom** |
| `gap-6` | Jarak antar kartu 1.5rem (24px) |

**Kartu individual:**
```html
<article class="group bg-white rounded-xl shadow-md p-6 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 border border-slate-100">
```
| Class | Fungsi |
|-------|--------|
| `group` | Menandai sebagai grup untuk `group-hover` pada anak |
| `bg-white rounded-xl shadow-md p-6` | Card standar: putih, radius XL, bayangan medium, padding 1.5rem |
| `hover:shadow-xl` | **Hover**: bayangan jadi extra large |
| `hover:-translate-y-1` | **Hover**: naik 0.25rem (4px) |
| `transition-all duration-300` | Animasi smooth 300ms untuk semua properti |
| `border border-slate-100` | Garis tepi tipis abu-abu |

**Ikon di dalam kartu:**
```html
<div class="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center mb-4 group-hover:bg-blue-600 group-hover:text-white transition-colors">
```
| Class | Fungsi |
|-------|--------|
| `w-12 h-12` | Kotak 3rem × 3rem (48×48px) |
| `bg-blue-100` | Background biru muda |
| `group-hover:bg-blue-600` | **Hover kartu induk**: background biru tua |
| `group-hover:text-white` | **Hover kartu induk**: ikon jadi putih |

### 4. Footer
```html
<footer class="bg-slate-900 text-white">
  <div class="mx-auto max-w-6xl px-4 py-8">
    <div class="flex flex-col md:flex-row items-center justify-between gap-4">
```
| Class | Fungsi |
|-------|--------|
| `bg-slate-900 text-white` | Background gelap, teks putih |
| `flex-col md:flex-row` | **Mobile**: kolom vertikal; **md+**: baris horizontal |
| `items-center justify-between` | Vertikal center, horizontal space-between |
| `gap-4` | Jarak 1rem antar item |

## Bagian Mudah vs Sulit

### ✅ Mudah Disusun dengan Utility Classes
1. **Grid responsif** — `grid-cols-1 md:grid-cols-3` sekali tulis, langsung responsif tanpa media query manual.
2. **Hover & transisi** — `hover:shadow-xl hover:-translate-y-1 transition-all` deklaratif, tidak perlu CSS terpisah.
3. **Spacing konsisten** — `gap-6`, `p-6`, `mb-4` menggunakan design system Tailwind (skala spacing 4px).
4. **Warna & varian** — `bg-blue-600`, `hover:bg-blue-700`, `group-hover:bg-blue-600` terintegrasi dengan tema.
5. **Sticky navbar** — `sticky top-0 z-50` satu baris, tanpa `position: sticky` manual.

### ⚠️ Sulit Dibaca / Memerlukan Kebiasaan
1. **String class panjang** — Satu elemen bisa punya 10+ class (misal kartu: `group bg-white rounded-xl shadow-md p-6 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 border border-slate-100`). Perlu pemformatan baris atau IDE extension (Tailwind CSS IntelliSense) agar terbaca.
2. **Variant `group-hover`** — Logika "hover parent mempengaruhi child" bergantung urutan DOM dan class `group` di parent. Jika lupa `group` di parent, `group-hover` di child tidak berfungsi.
3. **Responsive prefix berulang** — `md:grid-cols-3`, `md:flex-row`, `md:text-5xl` ditulis berulang di tiap elemen. Di CSS biasa cukup satu `@media`.
4. **Debugging di DevTools** — Styles pane menampilkan banyak utility class, sulit mencari properti CSS asli (misal `margin-top` vs `mt-4`). Perlu tab "Computed" atau extension Tailwind.

## Kesimpulan
Utility-first **sangat efisien** untuk:
- Layout grid/flex responsif
- State-based styling (hover, focus, dark mode)
- Spacing & sizing konsisten via design system

Utility-first **kurang cocok** untuk:
- Animasi kompleks (keyframes, multiple steps)
- Pseudo-elements rumit (`::before`, `::after` dengan content dinamis)
- Tim yang belum terbiasa (learning curve class naming)

**Solusi praktis**: Bungkus pola berulang jadi **komponen Svelte/React/Vue** (seperti `CardComponent.svelte` di Pertemuan 3) sehingga HTML bersih, utility hanya ditulis sekali di file komponen.