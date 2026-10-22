const express = require('express');
const routes = require('./routes');

const app = express();

app.use(express.json());

app.use('/api/v1', routes);

app.use((_req, res) => {
  res.status(404).json({ status: false, message: 'Endpoint tidak ditemukan' });
});

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ status: false, message: 'Terjadi kesalahan pada server' });
});

module.exports = app;