const express = require('express');
const { jadwal, peserta } = require('../data/mock');
const authRouter = require('./auth');
const adminRouter = require('./admin');

const router = express.Router();

// Route jadwal (dari Pertemuan 2)
router.get('/jadwal', (_req, res) => {
  res.json({ status: true, message: 'Daftar jadwal', data: jadwal });
});

router.get('/jadwal/:id', (req, res) => {
  const item = jadwal.find((j) => j.id === Number(req.params.id));
  if (!item) return res.status(404).json({ status: false, message: 'Jadwal tidak ditemukan' });
  res.json({ status: true, message: 'Detail jadwal', data: item });
});

// Route peserta (dari Pertemuan 2)
router.get('/peserta', (_req, res) => {
  res.json({ status: true, message: 'Daftar peserta', data: peserta });
});

router.get('/peserta/:id', (req, res) => {
  const item = peserta.find((p) => p.id === Number(req.params.id));
  if (!item) return res.status(404).json({ status: false, message: 'Peserta tidak ditemukan' });
  res.json({ status: true, message: 'Detail peserta', data: item });
});

// Route auth dan admin (Pertemuan 3)
router.use('/auth', authRouter);
router.use('/admin', adminRouter);

module.exports = router;