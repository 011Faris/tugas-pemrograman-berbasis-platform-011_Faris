const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-pertemuan-3-jangan-pakai-produksi';

function ambilToken(req) {
  // Token dikirim di header seperti ini: "Authorization: Bearer <token>"
  const header = req.headers.authorization || '';
  const [kata, token] = header.split(' ');
  if (kata !== 'Bearer' || !token) return null;
  return token;
}

// Penjaga 1: sudah login belum? (kalau gagal → 401)
function requireAuth(req, res, next) {
  const token = ambilToken(req);
  if (!token) {
    return res.status(401).json({ status: false, message: 'Token tidak ada. Sertakan Authorization: Bearer <token>' });
  }
  try {
    const isi = jwt.verify(token, JWT_SECRET); // cek tanda tangan + cek kedaluwarsa
    req.user = isi; // simpan info user: { sub, nim, nama, role }
    return next(); // lolos, lanjut ke penjaga berikutnya
  } catch (err) {
    return res.status(401).json({ status: false, message: 'Token tidak valid atau kedaluwarsa' });
  }
}

// Penjaga 2: perannya cukup tidak? (kalau gagal → 403)
function requireRole(...yangBoleh) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ status: false, message: 'Belum login' });
    }
    if (!yangBoleh.includes(req.user.role)) {
      return res.status(403).json({ status: false, message: `Hanya ${yangBoleh.join('/')} yang boleh mengakses` });
    }
    return next();
  };
}

module.exports = { requireAuth, requireRole };