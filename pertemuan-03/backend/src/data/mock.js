const bcrypt = require('bcryptjs');

const jadwal = [
  { id: 1, hari: 'Senin', mataKuliah: 'Pemrograman Berbasis Platform', jam: '08.00-10.00', ruang: 'Lab RPL' },
  { id: 2, hari: 'Selasa', mataKuliah: 'Basis Data', jam: '10.00-12.00', ruang: 'Lab DB' },
  { id: 3, hari: 'Rabu', mataKuliah: 'Jaringan Komputer', jam: '13.00-15.00', ruang: 'Lab Jarkom' },
];

const peserta = [
  { id: 1, nim: '2026001', nama: 'Admin Lab', kelompok: 1 },
  { id: 2, nim: '2026002', nama: 'Mahasiswa', kelompok: 1 },
];

const users = [
  { id: 1, nim: '2026001', nama: 'Admin Lab', role: 'ADMIN', passwordHash: bcrypt.hashSync('admin123', 10) },
  { id: 2, nim: '2026002', nama: 'Mahasiswa', role: 'MAHASISWA', passwordHash: bcrypt.hashSync('mhs123', 10) },
];

module.exports = { jadwal, peserta, users };