# Tugas Mandiri 4 — Analisis Struktur & Validitas JWT

## Payload Token (Hasil Login Praktikum)

```json
{
  "sub": "2",
  "nim": "2026002",
  "nama": "Mahasiswa",
  "role": "MAHASISWA",
  "iat": 1792650914,
  "exp": 1792654514
}
```

> Token asli: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwibmltIjoiMjAyNjAwMiIsIm5hbWEiOiJNYWhhc2lzd2EiLCJyb2xlIjoiTUFIQVNJU1dBIiwiaWF0IjoxNzkyNjUwOTE0LCJleHAiOjE3OTI2NTQ1MTR9.v2XE5oj_t3bIwPexdt6FwcDO_i622tSMgsytnsYzR9Rc`

## Analisis Klaim

| Klaim | Nilai | Fungsi |
|-------|-------|--------|
| **sub** | `"2"` | **Subject** — Identifier unik pengguna (primary key di database). Digunakan server untuk `WHERE id = sub` saat `GET /auth/me`. |
| **nim** | `"2026002"` | **NIM** — Nomor induk mahasiswa, untuk ditampilkan di UI / logging. |
| **nama** | `"Mahasiswa"` | **Nama lengkap** — Untuk sapaan "Halo Mahasiswa" di frontend. |
| **role** | `"MAHASISWA"` | **Peran (Role)** — Digunakan `requireRole()` untuk authorization. Contoh: `requireRole('ADMIN')` cek `req.user.role === 'ADMIN'`. |
| **iat** | `1792650914` | **Issued At** — Waktu token diterbitkan (Unix timestamp detik). `Tue Oct 22 2026 12:35:14 GMT+0000`. |
| **exp** | `1792654514` | **Expiration** — Waktu token kedaluwarsa (Unix timestamp detik). `Tue Oct 22 2026 13:35:14 GMT+0000`. **Selisih = 3600 detik (1 jam)**. |

### Perbedaan `iat` vs `exp`
- **`iat` (Issued At)**: Kapan token **dibuat**. Berguna untuk audit log, mengetahui kapan user login.
- **`exp` (Expiration)**: Kapan token **tidak lagi valid**. Server **otomatis tolak** (401) jika `now > exp`. Client harus login ulang sebelum `exp` untuk mendapat token baru.

## Pengujian Token Dimodifikasi

### 1. Token Asli (Valid) → `GET /auth/me`
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwibmltIjoiMjAyNjAwMiIsIm5hbWEiOiJNYWhhc2lzd2EiLCJyb2xlIjoiTUF...v2XE5oj_t3bIwPexdt6FwcDO_i622tSMgsytnsYzR9Rc" \
  http://localhost:3000/api/v1/auth/me
```
**Hasil**: `200 OK`
```json
{
  "status": true,
  "message": "Profil berhasil diambil",
  "data": { "id": 2, "nim": "2026002", "nama": "Mahasiswa", "role": "MAHASISWA" }
}
```

### 2. Token Dimodifikasi (Payload diubah, signature tidak dibangun ulang) → `GET /auth/me`

**Modifikasi**: Ubah `"role":"MAHASISWA"` → `"role":"ADMIN"` di payload (base64url decode → edit → encode), **tanpa** menghitung ulang signature.

Token palsu: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwibmltIjoiMjAyNjAwMiIsIm5hbWEiOiJNYWhhc2lzd2EiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3OTI2NTA5MTQsImV4cCI6MTc5MjY1NDUxNH0.v2XE5oj_t3bIwPexdt6FwcDO_i622tSMgsytnsYzR9Rc`

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwibmltIjoiMjAyNjAwMiIsIm5hbWEiOiJNYWhhc2lzd2EiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3OTI2NTA5MTQsImV4cCI6MTc5MjY1NDUxNH0.v2XE5oj_t3bIwPexdt6FwcDO_i622tSMgsytnsYzR9Rc" \
  http://localhost:3000/api/v1/auth/me
```
**Hasil**: `401 Unauthorized`
```json
{
  "status": false,
  "message": "Token tidak valid atau kedaluwarsa"
}
```

## Mengapa Verifikasi Signature Gagal?

JWT signature = `HMAC_SHA256(base64url(header) + "." + base64url(payload), JWT_SECRET)`

1. **Header + Payload** digabung dengan titik → string `signing_input`.
2. **Signature** = HMAC(`signing_input`, `JWT_SECRET`) → hanya server yang tahu `JWT_SECRET` bisa buat signature valid.
3. Saat **memodifikasi payload** (misal ubah role), `signing_input` berubah.
4. Signature **lama** (yang masih terlampir di token) = HMAC(`signing_input_lama`, `JWT_SECRET`).
5. Server verifikasi: hitung `HMAC(signing_input_baru, JWT_SECRET)` → **tidak sama** dengan signature lama.
6. **Verifikasi gagal** → return 401.

### Kenapa tidak bisa "hitung ulang signature" sendiri?
- `JWT_SECRET` **hanya ada di server** (file `.env`, tidak di-commit ke Git).
- Tanpa `JWT_SECRET`, imposible membuat signature yang cocok.
- Mencoba brute-force `JWT_SECRET` dari token = **computationally infeasible** (HMAC-SHA256 dengan secret 32+ karakter).

### Bukti Keamanan
Meskipun **siapapun bisa baca** payload (base64url decode), **tidak ada yang bisa ubah** payload tanpa terdeteksi karena:
- Payload + Header **terikat** dengan signature.
- Perubahan 1 bit saja → signature beda → server tolak 401.
- Inilah mengapa **password dilarang di payload** — payload terbaca semua orang, tapi signature melindungi **integritas**, bukan kerahasiaan.

## Tabel Hasil Pengujian

| Token yang diuji | Endpoint | Hasil yang diharapkan | Hasil pengujian |
|------------------|----------|----------------------|-----------------|
| Token asli yang masih berlaku | `GET /auth/me` | 200 | ✅ 200 OK — Profil berhasil diambil |
| Token dengan payload diubah tanpa memperbarui tanda tangan | `GET /auth/me` | 401 | ✅ 401 Unauthorized — Token tidak valid atau kedaluwarsa |

## Kesimpulan
- **`sub`** = identitas user (untuk lookup DB)
- **`role`** = autorisasi (untuk `requireRole`)
- **`iat`/`exp`** = masa berlaku token (1 jam)
- **Modifikasi payload tanpa signature baru → 401** karena HMAC verification gagal.
- **Keamanan JWT bergantung pada kerahasiaan `JWT_SECRET`** — jangan pernah commit ke Git!