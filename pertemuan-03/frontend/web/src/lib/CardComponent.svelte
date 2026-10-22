<script lang="ts">
  import { login, fetchMe } from './api.js';

  interface Props {
    title?: string;
    subtitle?: string;
  }

  let { title = 'Jadwal Praktikum', subtitle = 'Senin, 08.00 — Lab RPL · Gaya komponen' }: Props = $props();

  let nim: string = $state('');
  let password: string = $state('');
  let msg: string = $state('');
  let meStatus: string = $state('');

  async function masuk(): Promise<void> {
    try {
      const data = await login(nim, password);
      msg = `Halo ${data.user.nama} (${data.user.role})`;
      const me = await fetchMe();
      meStatus = `GET /auth/me → ${me.status}`;
      console.log('GET /auth/me →', me.status, me.body);
    } catch (e) {
      msg = e instanceof Error ? e.message : 'Login gagal';
    }
  }
</script>

<div class="card">
  <h2>{title}</h2>
  <p>{subtitle}</p>
  <input class="input" bind:value={nim} placeholder="NIM" />
  <input class="input" type="password" bind:value={password} placeholder="Password" />
  <button class="btn" onclick={masuk}>Masuk</button>
  <p>{msg}</p>
  <p>{meStatus}</p>
</div>

<style>
  .card { max-width: 380px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 8px 24px rgba(15,23,42,.08); }
  .card h2 { margin: 0 0 4px; font-size: 18px; }
  .card p { margin: 0 0 12px; color: #64748b; font-size: 14px; }
  .input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 8px; box-sizing: border-box; }
  .btn { width: 100%; padding: 10px; border: 0; border-radius: 8px; background: #2563eb; color: #fff; font-weight: 700; cursor: pointer; }
  .btn:hover { background: #1d4ed8; }
</style>