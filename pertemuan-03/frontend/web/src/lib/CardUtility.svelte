<script lang="ts">
  import { login, fetchMe } from './api.js';

  interface Props {
    title?: string;
    subtitle?: string;
  }

  let { title = 'Jadwal Praktikum', subtitle = 'Senin, 08.00 — Lab RPL · Gaya utility' }: Props = $props();

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

<div class="mx-auto max-w-sm rounded-xl bg-white p-6 shadow-md">
  <h2 class="text-lg font-bold text-slate-900">{title}</h2>
  <p class="mb-3 text-sm text-slate-500">{subtitle}</p>
  <input bind:value={nim} placeholder="NIM" class="mb-2 w-full rounded-lg border border-slate-300 px-3 py-2" />
  <input type="password" bind:value={password} placeholder="Password" class="mb-2 w-full rounded-lg border border-slate-300 px-3 py-2" />
  <button onclick={masuk} class="w-full rounded-lg bg-blue-600 px-4 py-2 font-semibold text-white hover:bg-blue-700">Masuk</button>
  <p class="mt-2 text-sm text-slate-600">{msg}</p>
  <p class="text-sm text-slate-400">{meStatus}</p>
</div>