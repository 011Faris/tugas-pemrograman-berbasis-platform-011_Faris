#!/bin/bash
# Script otomatis untuk memeriksa Pertemuan 3
# Jalankan: bash backend/check-p3.sh (backend harus hidup di terminal lain)

set -e

BASE="http://localhost:3000/api/v1"

echo "=== CHECK P3: Register ==="
REG=$(curl -s -X POST "$BASE/auth/register" -H "Content-Type: application/json" -d '{"nim":"2026003","nama":"Citra","password":"citra123"}')
echo "$REG" | grep -q '"status":true' && echo "✓ Register 201" || (echo "✗ Register gagal"; echo "$REG"; exit 1)
echo "$REG" | grep -q '"passwordHash"' && (echo "✗ passwordHash terkirim!"; exit 1) || echo "✓ passwordHash tidak terkirim"

echo ""
echo "=== CHECK P3: Register duplikat ==="
DUP=$(curl -s -X POST "$BASE/auth/register" -H "Content-Type: application/json" -d '{"nim":"2026003","nama":"Citra","password":"citra123"}')
echo "$DUP" | grep -q '"status":false' && echo "$DUP" | grep -q '400' && echo "✓ Duplikat 400" || (echo "✗ Duplikat gagal"; echo "$DUP"; exit 1)

echo ""
echo "=== CHECK P3: Login mahasiswa ==="
LOGIN_MHS=$(curl -s -X POST "$BASE/auth/login" -H "Content-Type: application/json" -d '{"nim":"2026002","password":"mhs123"}')
echo "$LOGIN_MHS" | grep -q '"status":true' && echo "✓ Login mahasiswa 200" || (echo "✗ Login mahasiswa gagal"; echo "$LOGIN_MHS"; exit 1)
TOKEN_MHS=$(echo "$LOGIN_MHS" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$TOKEN_MHS" ] && echo "✓ Token mahasiswa ada" || (echo "✗ Token kosong"; exit 1)

echo ""
echo "=== CHECK P3: Login admin ==="
LOGIN_ADM=$(curl -s -X POST "$BASE/auth/login" -H "Content-Type: application/json" -d '{"nim":"2026001","password":"admin123"}')
echo "$LOGIN_ADM" | grep -q '"status":true' && echo "✓ Login admin 200" || (echo "✗ Login admin gagal"; echo "$LOGIN_ADM"; exit 1)
TOKEN_ADM=$(echo "$LOGIN_ADM" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$TOKEN_ADM" ] && echo "✓ Token admin ada" || (echo "✗ Token kosong"; exit 1)

echo ""
echo "=== CHECK P3: /me tanpa token ==="
ME_NOTOK=$(curl -s -w "\n%{http_code}" "$BASE/auth/me")
CODE=$(echo "$ME_NOTOK" | tail -1)
[ "$CODE" = "401" ] && echo "✓ /me tanpa token → 401" || (echo "✗ /me tanpa token bukan 401 ($CODE)"; exit 1)

echo ""
echo "=== CHECK P3: /me dengan token mahasiswa ==="
ME_OK=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN_MHS" "$BASE/auth/me")
CODE=$(echo "$ME_OK" | tail -1)
[ "$CODE" = "200" ] && echo "✓ /me dengan token → 200" || (echo "✗ /me dengan token bukan 200 ($CODE)"; exit 1)

echo ""
echo "=== CHECK P3: /me dengan token palsu ==="
ME_FAKE=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer ${TOKEN_MHS}x" "$BASE/auth/me")
CODE=$(echo "$ME_FAKE" | tail -1)
[ "$CODE" = "401" ] && echo "✓ /me token palsu → 401" || (echo "✗ /me token palsu bukan 401 ($CODE)"; exit 1)

echo ""
echo "=== CHECK P3: Mahasiswa akses /admin/rekap ==="
ADM_MHS=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN_MHS" "$BASE/admin/rekap")
CODE=$(echo "$ADM_MHS" | tail -1)
[ "$CODE" = "403" ] && echo "✓ Mahasiswa akses admin → 403" || (echo "✗ Mahasiswa akses admin bukan 403 ($CODE)"; exit 1)

echo ""
echo "=== CHECK P3: Admin akses /admin/rekap ==="
ADM_OK=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN_ADM" "$BASE/admin/rekap")
CODE=$(echo "$ADM_OK" | tail -1)
[ "$CODE" = "200" ] && echo "✓ Admin akses admin → 200" || (echo "✗ Admin akses admin bukan 200 ($CODE)"; exit 1)

echo ""
echo "=== CHECK P3: Secret hygiene ==="
cd "$(dirname "$0")/.."
git ls-files --error-unmatch backend/.env 2>/dev/null && echo "✗ BAHAYA: .env terlacak" && exit 1 || echo "✓ AMAN: .env tidak terlacak"

echo ""
echo "=== SEMUA CHECK LULUS ==="