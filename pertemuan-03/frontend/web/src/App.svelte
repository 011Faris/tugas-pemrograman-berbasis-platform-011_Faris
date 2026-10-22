<script lang="ts">
  import CardComponent from './lib/CardComponent.svelte';
  import CardUtility from './lib/CardUtility.svelte';
</script>

<main class="mx-auto max-w-4xl p-6">
  <h1 class="mb-1 text-2xl font-bold text-slate-900">Pertemuan 3 — Satu Kartu, Dua Gaya</h1>
  <p class="mb-6 text-sm text-slate-500">
    Kiri: gaya component-based (CSS pada style tag komponen).
    Kanan: gaya utility-first (Tailwind). Keduanya memanggil API login yang sama.
  </p>
  <div class="grid gap-6 md:grid-cols-2">
    <CardComponent />
    <CardUtility />
  </div>
</main>