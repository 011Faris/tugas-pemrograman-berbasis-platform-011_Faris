// Alamat backend. Samakan dengan port pada backend/.env (default 3000).
export const BASE: string = 'http://localhost:3000/api/v1';

export interface AuthUser {
  id: number;
  nim: string;
  nama: string;
  role: string;
}

export interface LoginData {
  token: string;
  user: AuthUser;
}

interface ApiEnvelope<T> {
  status: boolean;
  message: string;
  data: T;
}

// Mengirim NIM dan kata sandi ke endpoint login.
// Berhasil: token disimpan ke localStorage, data user dikembalikan.
// Gagal: throw Error berisi status dan pesan server.
// Server mati: throw Error pesan koneksi (fetch hanya throw saat
// request tidak sampai, misalnya ERR_CONNECTION_REFUSED).
export async function login(nim: string, password: string): Promise<LoginData> {
  let res: Response;
  try {
    res = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nim, password }),
    });
  } catch {
    throw new Error('Tidak dapat terhubung ke server. Pastikan backend berjalan pada http://localhost:3000.');
  }
  const body: ApiEnvelope<LoginData> = await res.json();
  if (!res.ok) {
    throw new Error(`Gagal (${res.status}): ${body.message}`);
  }
  localStorage.setItem('token', body.data.token);
  return body.data;
}

export interface MeResult {
  status: number;
  body: ApiEnvelope<AuthUser>;
}

// Memanggil route terlindungi dengan token tersimpan.
// Dipakai untuk membuktikan token berfungsi (200) atau ditolak (401).
export async function fetchMe(): Promise<MeResult> {
  const token: string | null = localStorage.getItem('token');
  let res: Response;
  try {
    res = await fetch(`${BASE}/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    });
  } catch {
    throw new Error('Tidak dapat terhubung ke server. Pastikan backend berjalan pada http://localhost:3000.');
  }
  return { status: res.status, body: await res.json() };
}