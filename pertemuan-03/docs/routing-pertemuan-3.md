# Routing & Testing — Pertemuan 3

Dokumen ini berisi tabel pengujian hasil praktikum Pertemuan 3. Isi kolom "Hasil saya" dengan hasil pengujianmu sendiri.

## Tabel Pengujian

| No. | Yang dicoba | Hasil yang diharapkan | Hasil saya |
|-----|-------------|----------------------|------------|
| 1 | Daftar user baru (Tahap 5 langkah 2) | 201, tidak ada password terkirim | ✅ 201, passwordHash tidak terkirim |
| 2 | Daftar dengan NIM yang sama 2 kali | 400, NIM sudah terdaftar | ✅ 400, NIM sudah terdaftar |
| 3 | Login benar | 200 + token | ✅ 200 + token |
| 4 | Login password salah | 401, NIM atau password salah | ✅ 401, NIM atau password salah |
| 5 | Buka /me tanpa token | 401, Token tidak ada | ✅ 401, Token tidak ada |
| 6 | Buka /me dengan token palsu | 401, tidak valid | ✅ 401, Token tidak valid atau kedaluwarsa |
| 7 | Mahasiswa buka /admin/rekap | 403, Hanya ADMIN | ✅ 403, Hanya ADMIN yang boleh mengakses |
| 8 | Admin buka /admin/rekap | 200 | ✅ 200, Rekap khusus admin |
| 9 | Buka halaman web (dua kartu berdampingan) | Tampilan mirip, kode beda pendekatan | ✅ Tampil berdampingan di localhost:5173 |

## Screenshot Wajib

1. **Register 201** - Response body registrasi user baru
2. **Login 200** - Response body login dengan token
3. **/me 401 tanpa token** - Response 401 Token tidak ada
4. **/me 200 dengan token** - Response 200 profil user
5. **/admin/rekap 403 (mahasiswa)** - Response 403 Hanya ADMIN
6. **/admin/rekap 200 (admin)** - Response 200 rekap admin
7. **Web dua kartu berdampingan** - Screenshot halaman web localhost:5173 menampilkan CardComponent (kiri) dan CardUtility (kanan)

## Catatan

- Samarkan token di semua bukti (hanya tampilkan 10-15 karakter awal + ...)
- Pastikan backend `.env` tidak terlacak Git: `git ls-files --error-unmatch backend/.env 2>/dev/null && echo "BAHAYA" || echo "AMAN"` → **AMAN**
- Pastikan tidak ada token JWT lengkap di laporan atau kode client: `git grep -nE 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' -- docs web mobile || echo "AMAN"` → **AMAN**