const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { users } = require('../data/mock');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-pertemuan-3-jangan-pakai-produksi';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1h';

function buatToken(user) {
  return jwt.sign(
    { sub: user.id, nim: user.nim, nama: user.nama, role: user.role },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN },
  );
}

// DAFTAR: POST /api/v1/auth/register
router.post('/register', async (req, res) => {
  try {
    const { nim, nama, password, role = 'MAHASISWA' } = req.body || {};
    if (!nim || !nama || !password) {
      return res.status(400).json({ status: false, message: 'nim, nama, dan password wajib diisi' });
    }
    if (users.some((u) => u.nim === nim)) {
      return res.status(400).json({ status: false, message: 'NIM sudah terdaftar' });
    }
    if (!['ADMIN', 'MAHASISWA'].includes(role)) {
      return res.status(400).json({ status: false, message: 'role harus ADMIN atau MAHASISWA' });
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const created = { id: Math.max(...users.map((u) => u.id), 0) + 1, nim, nama, role, passwordHash };
    users.push(created);
    const { passwordHash: _, ...aman } = created;
    return res.status(201).json({ status: true, message: 'Registrasi berhasil', data: aman });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: false, message: 'Terjadi kesalahan pada server' });
  }
});

// LOGIN: POST /api/v1/auth/login
router.post('/login', async (req, res) => {
  try {
    const { nim, password } = req.body || {};
    if (!nim || !password) {
      return res.status(400).json({ status: false, message: 'nim dan password wajib diisi' });
    }
    const user = users.find((u) => u.nim === nim);
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return res.status(401).json({ status: false, message: 'NIM atau password salah' });
    }
    const token = buatToken(user);
    return res.status(200).json({
      status: true,
      message: 'Login berhasil',
      data: { token, user: { id: user.id, nim: user.nim, nama: user.nama, role: user.role } },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: false, message: 'Terjadi kesalahan pada server' });
  }
});

// PROFIL: GET /api/v1/auth/me (harus bawa token!)
router.get('/me', requireAuth, (req, res) => {
  const user = users.find((u) => u.id === req.user.sub);
  if (!user) return res.status(404).json({ status: false, message: 'User tidak ditemukan' });
  const { passwordHash: _, ...aman } = user;
  return res.status(200).json({ status: true, message: 'Profil berhasil diambil', data: aman });
});

module.exports = router;