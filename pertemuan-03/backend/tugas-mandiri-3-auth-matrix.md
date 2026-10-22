# Tugas Mandiri 3 — Matriks Authentication & Authorization

## Peran Pengguna (Role)

Aplikasi **E-Library Kampus** memiliki 3 peran:

| Peran | Deskripsi |
|-------|-----------|
| **Anggota** | Mahasiswa/dosen yang meminjam buku |
| **Pustakawan** | Petugas perpustakaan yang mengelola katalog & peminjaman |
| **Pimpinan** | Kepala perpustakaan yang melihat rekap & laporan |

## Fitur & Endpoint

| Fitur | Deskripsi | Endpoint |
|-------|-----------|----------|
| Pinjam buku | Anggota meminjam buku yang tersedia | `POST /peminjaman` |
| Kembalikan buku | Anggota mengembalikan buku pinjaman | `POST /peminjaman/{id}/kembali` |
| Tambah katalog | Pustakawan menambah buku baru ke sistem | `POST /buku` |
| Edit katalog | Pustakawan mengubah data buku | `PUT /buku/{id}` |
| Lihat rekap pengadaan | Pimpinan melihat statistik pengadaan buku | `GET /laporan/pengadaan` |
| Kelola pengguna | Pimpinan menambah/mengubah/menghapus akun pengguna | `POST|PUT|DELETE /pengguna` |

## Matriks Hak Akses

| Fitur | Anggota | Pustakawan | Pimpinan | Endpoint |
|-------|---------|------------|----------|----------|
| Pinjam buku | ✅ | ✅ | ✅ | `POST /peminjaman` |
| Kembalikan buku | ✅ | ✅ | ✅ | `POST /peminjaman/{id}/kembali` |
| Tambah katalog | ❌ (403) | ✅ | ✅ | `POST /buku` |
| Edit katalog | ❌ (403) | ✅ | ❌ (403) | `PUT /buku/{id}` |
| Lihat rekap pengadaan | ❌ (403) | ❌ (403) | ✅ | `GET /laporan/pengadaan` |
| Kelola pengguna | ❌ (403) | ❌ (403) | ✅ | `POST|PUT|DELETE /pengguna` |

> **Catatan**: ✅ = diizinkan (200), ❌ = ditolak dengan **403 Forbidden** karena peran tidak mencukupi (identitas sudah terverifikasi).

## Alasan Kode Status 401 vs 403

### 401 Unauthorized — "Siapa Anda?"
- **Kapan**: Permintaan **tanpa token**, token **tidak valid** (signature salah), atau token **kedaluwarsa** (expired).
- **Contoh pada matriks**:
  - `GET /laporan/pengadaan` tanpa header `Authorization` → **401**
  - `POST /buku` dengan token yang diubah 1 karakter → **401** (signature invalid)
  - Token expired (lebih dari 1 jam sejak login) → **401**
- **Tindakan client**: Arahkan ke halaman login / minta kredensial ulang.

### 403 Forbidden — "Anda siapa, tapi tidak boleh"
- **Kapan**: Token **valid**, identitas **terverifikasi**, tapi **peran (role)** tidak termasuk daftar yang diizinkan untuk endpoint tersebut.
- **Contoh pada matriks**:
  - Anggota (token valid) `POST /buku` → **403** "Hanya PUSTAKAWAN/PIMPINAN yang boleh mengakses"
  - Pustakawan (token valid) `GET /laporan/pengadaan` → **403** "Hanya PIMPINAN yang boleh mengakses"
  - Pustakawan (token valid) `DELETE /pengguna/123` → **403** "Hanya PIMPINAN yang boleh mengakses"
- **Tindakan client**: Tampilkan pesan "Akses ditolak: Anda tidak memiliki izin untuk fitur ini", **jangan** arahkan ke login.

## Analisis: Jika Endpoint Hanya Pakai `requireAuth` Tanpa `requireRole`

> **Contoh**: Endpoint `POST /buku` (tambah katalog) hanya dipasang `requireAuth`, **tanpa** `requireRole(['PUSTAKAWAN', 'PIMPINAN'])`.

**Apa yang terjadi**:
1. Anggota login → dapat token valid (role: ANGGOTA).
2. Anggota kirim `POST /buku` dengan token valid.
3. `requireAuth` memverifikasi token → **lolos** (token asli, belum expired).
4. Karena **tidak ada `requireRole`**, request lanjut ke handler.
5. Handler menyimpan buku baru ke database **atas nama Anggota**.
6. **Pelanggaran keamanan**: Data katalog bisa diubah oleh siapa saja yang login, bukan hanya Pustakawan.

**Dampak nyata**:
- Anggota bisa menambah buku fiktif / spam katalog.
- Pustakawan tidak bisa membedakan buku yang ditambah petugas resmi vs anggota.
- Audit trail rusak: tidak ada accountability siapa yang menambah data.
- Melanggar prinsip **least privilege** (berikan hak minimal yang diperlukan).

**Solusi**: Selalu pasang **dua lapis middleware** berurutan:
```javascript
router.post('/buku', requireAuth, requireRole('PUSTAKAWAN', 'PIMPINAN'), handler);
```
1. `requireAuth` → cek identitas (401 jika gagal)
2. `requireRole` → cek peran (403 jika gagal)
3. Handler → hanya dijalankan jika keduanya lolos

**Urutan wajib**: `requireAuth` **dulu**, baru `requireRole`. Kalau dibalik, `requireRole` error karena `req.user` belum ada (belum diverifikasi).