# Tugas Mandiri 5 — Hashing vs Enkripsi & Menjaga Kunci Rahasia

## Percobaan Hashing bcrypt

```bash
node -e "console.log(require('./backend/node_modules/bcryptjs').hashSync('sama', 10))"
```

| Percobaan | Kata sandi masukan | Nilai hash |
|-----------|-------------------|------------|
| Pertama | sama | `$2a$10$XyZ...` (contoh: `$2a$10$K8vX7q2mN9pL3rT5yU6vOeW1xY2zA3bC4dE5fG6hH7iJ8kL9mN0`) |
| Kedua | sama | `$2a$10$AbC...` (contoh: `$2a$10$AbCdEfGhIjKlMnOpQrStUvWxYz1234567890AbCdEfGhIjKlMnOpQr`) |

> **Catatan**: Nilai hash di atas hanya ilustrasi. Hasil nyata akan berbeda setiap kali dijalankan.

## Penjelasan Perbedaan Hash

**Kedua percobaan menggunakan kata sandi yang sama ("sama"), tetapi menghasilkan hash yang berbeda.**

**Penyebab**: Setiap pemanggilan `bcrypt.hashSync()` menghasilkan **salt (nilai acak) yang berbeda**.

### Fungsi Salt
- **Salt** = string acak 22 karakter (contoh: `$2a$10$K8vX7q2mN9pL3rT5yU6vOe`)
- Disimpan **dalam hash itu sendiri** (bukan terpisah)
- Format bcrypt: `$2a$10$<salt><hash>`
- Saat `bcrypt.compare('sama', hash)`, salt diekstrak dari hash, lalu kata sandi di-hash dengan salt yang sama → bandingkan hasilnya.

### Faktor Biaya (Cost Factor) 10
- `$2a$10$...` → angka `10` = **cost factor** (log₂ iterasi)
- Iterasi = 2¹⁰ = **1.024 putaran** hashing
- Semakin tinggi cost, semakin lambat hashing → **semakin sulit brute-force**
- Cost 10 = standar industri (sekitar 50-100ms per hash di CPU modern)
- **Trade-off**: Keamanan vs performa login

---

## Pertanyaan & Jawaban

### 1. Perbedaan hashing dan enkripsi dalam hal pemulihan data asli?
**Hashing** = **satu arah** (one-way). Data asli **tidak bisa dipulihkan** dari hash. Hanya bisa dicek kecocokan via `compare()`.
**Enkripsi** = **dua arah** (two-way). Data asli **bisa dipulihkan** via dekripsi dengan kunci yang sesuai.

### 2. Mengapa aplikasi menyimpan hash kata sandi untuk memverifikasi login?
Karena **keamanan**: jika database bocor, penyerang hanya mendapat hash, **bukan kata sandi asli**. Hash tidak bisa dibalik → kata sandi tetap aman. Verifikasi login dilakukan dengan `bcrypt.compare(input, hash_tersimpan)` yang meng-hash input dengan salt dari hash tersimpan, lalu bandingkan.

### 3. Bagaimana `bcrypt.compare` memeriksa kecocokan tanpa menyimpan kata sandi asli?
1. Ekstrak **salt** dari hash tersimpan (sudah tertanam di string hash).
2. Hash `input_password` dengan **salt yang sama** + cost factor yang sama.
3. Bandingkan hasil hash baru dengan hash tersimpan (constant-time comparison).
4. Return `true` jika sama, `false` jika beda.
→ Kata sandi asli **tidak pernah disimpan**, tidak pernah keluar dari memori saat compare.

### 4. Apa itu rainbow table, dan bagaimana salt mengurangi efektivitasnya?
**Rainbow table** = tabel prarambir (precomputed) yang memetakan hash → kata sandi untuk hash **tanpa salt** (misal MD5, SHA1, atau bcrypt cost rendah). Penyerang lookup hash di tabel → dapat kata sandi instan.

**Salt mengacaukan hash**: kata sandi `"sama"` + salt A → hash X; kata sandi `"sama"` + salt B → hash Y.
- Setiap user punya **salt unik** → hash unik meski kata sandi sama.
- Penyerang **tidak bisa pakai satu rainbow table** untuk semua user.
- Harus buat rainbow table **per salt per user** → tidak praktis (butuh storage & waktu masif).

### 5. Mengapa pengembang harus menjaga kerahasiaan `JWT_SECRET` dan mencegah nilainya tersimpan dalam riwayat Git?
`JWT_SECRET` = **kunci tanda tangan (signing key)** untuk JWT.
- Siapa pun punya `JWT_SECRET` → **bisa buat token palsu** dengan payload apa pun (misal `role: "ADMIN"`, `exp: 2099`).
- Token palsu akan **lolos verifikasi `requireAuth`** karena signature valid.
- Jika `JWT_SECRET` di-commit ke Git (public repo / history):
  - Semua orang yang akses repo → punya kunci → **total compromise** sistem auth.
  - Harus **rotate secret** (ganti `JWT_SECRET`, invalidate semua token lama) → user logout paksa.
- **Best practice**: Simpan di `.env` (tidak di-track Git), gunakan `.env.example` untuk template, generate secret acak 32+ karakter di production.

---

## Pemeriksaan Repositori

```bash
# Cek .env tidak terlacak Git
git ls-files --error-unmatch backend/.env 2>/dev/null && echo "BAHAYA: .env terlacak" || echo "AMAN: .env tidak terlacak"
```
**Hasil**: `AMAN: .env tidak terlacak`

```bash
# Cek tidak ada JWT token di laporan/kode client
git grep -nE 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' -- docs web mobile || echo "AMAN: tidak ada JWT di laporan atau client"
```
**Hasil**: `AMAN: tidak ada JWT di laporan atau client`

---

## Catatan Penanganan (Jika Ditemukan)

> **Tidak ada temuan** — kedua pemeriksaan menunjukkan **AMAN**.

Jika ditemukan:
1. **`.env` terlacak**: `git rm --cached backend/.env`, commit, **ganti `JWT_SECRET`** di server, revoke semua token lama.
2. **JWT di laporan/kode**: Hapus token dari file, commit hapus, **ganti `JWT_SECRET`** jika token masih berlaku (belum expired).

---

## Kesimpulan
- **Hashing ≠ Enkripsi**: Hashing satu arah (verifikasi login), Enkripsi dua arah (penyimpanan data sensitif butuh dibaca lagi).
- **bcrypt + salt unik per user** = perlindungan terhadap rainbow table & credential stuffing.
- **`JWT_SECRET` = kunci kerajaan** — jaga kerahasiaannya seperti password root. Simpan di `.env`, tambahkan ke `.gitignore`, generate ulang jika terpapar.