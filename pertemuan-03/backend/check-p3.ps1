#!/bin/bash
# Script otomatis untuk memeriksa Pertemuan 3 - PowerShell version
# Jalankan di PowerShell: .\backend\check-p3.ps1 (backend harus hidup di terminal lain)

$BASE = "http://localhost:3000/api/v1"

Write-Host "=== CHECK P3: Register ===" -ForegroundColor Green
$REG = Invoke-RestMethod -Uri "$BASE/auth/register" -Method Post -ContentType "application/json" -Body '{"nim":"2026010","nama":"TestUser","password":"test123"}'
if ($REG.status -eq $true) { Write-Host "OK Register 201" -ForegroundColor Green } else { Write-Host "FAIL Register gagal"; Write-Host $REG; exit 1 }
if ($REG.data -match "passwordHash") { Write-Host "FAIL passwordHash terkirim!"; exit 1 } else { Write-Host "OK passwordHash tidak terkirim" -ForegroundColor Green }

Write-Host ""
Write-Host "=== CHECK P3: Register duplikat ===" -ForegroundColor Green
try { 
    $DUP = Invoke-RestMethod -Uri "$BASE/auth/register" -Method Post -ContentType "application/json" -Body '{"nim":"2026010","nama":"TestUser","password":"test123"}'
    Write-Host "FAIL Duplikat seharusnya gagal tapi sukses"
    exit 1
} catch { 
    $code = $_.Exception.Response.StatusCode.value__
    $body = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($code -eq 400 -and $body.status -eq $false -and $body.message -match "terdaftar") { 
        Write-Host "OK Duplikat 400" -ForegroundColor Green 
    } else { 
        Write-Host "FAIL Duplikat gagal"; Write-Host $body; exit 1 
    } 
}

Write-Host ""
Write-Host "=== CHECK P3: Login mahasiswa ===" -ForegroundColor Green
$LOGIN_MHS = Invoke-RestMethod -Uri "$BASE/auth/login" -Method Post -ContentType "application/json" -Body '{"nim":"2026002","password":"mhs123"}'
if ($LOGIN_MHS.status -eq $true) { Write-Host "OK Login mahasiswa 200" -ForegroundColor Green } else { Write-Host "FAIL Login mahasiswa gagal"; Write-Host $LOGIN_MHS; exit 1 }
$TOKEN_MHS = $LOGIN_MHS.data.token
if ($TOKEN_MHS) { Write-Host "OK Token mahasiswa ada" -ForegroundColor Green } else { Write-Host "FAIL Token kosong"; exit 1 }

Write-Host ""
Write-Host "=== CHECK P3: Login admin ===" -ForegroundColor Green
$LOGIN_ADM = Invoke-RestMethod -Uri "$BASE/auth/login" -Method Post -ContentType "application/json" -Body '{"nim":"2026001","password":"admin123"}'
if ($LOGIN_ADM.status -eq $true) { Write-Host "OK Login admin 200" -ForegroundColor Green } else { Write-Host "FAIL Login admin gagal"; Write-Host $LOGIN_ADM; exit 1 }
$TOKEN_ADM = $LOGIN_ADM.data.token
if ($TOKEN_ADM) { Write-Host "OK Token admin ada" -ForegroundColor Green } else { Write-Host "FAIL Token kosong"; exit 1 }

Write-Host ""
Write-Host "=== CHECK P3: /me tanpa token ===" -ForegroundColor Green
try { Invoke-RestMethod -Uri "$BASE/auth/me" } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code -eq 401) { Write-Host "OK /me tanpa token -> 401" -ForegroundColor Green } else { Write-Host "FAIL /me tanpa token bukan 401 ($code)"; exit 1 } }

Write-Host ""
Write-Host "=== CHECK P3: /me dengan token mahasiswa ===" -ForegroundColor Green
try { $ME_OK = Invoke-RestMethod -Uri "$BASE/auth/me" -Headers @{Authorization = "Bearer $TOKEN_MHS"}; Write-Host "OK /me dengan token -> 200" -ForegroundColor Green } catch { Write-Host "FAIL /me dengan token gagal"; exit 1 }

Write-Host ""
Write-Host "=== CHECK P3: /me dengan token palsu ===" -ForegroundColor Green
try { Invoke-RestMethod -Uri "$BASE/auth/me" -Headers @{Authorization = "Bearer ${TOKEN_MHS}x"} } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code -eq 401) { Write-Host "OK /me token palsu -> 401" -ForegroundColor Green } else { Write-Host "FAIL /me token palsu bukan 401 ($code)"; exit 1 } }

Write-Host ""
Write-Host "=== CHECK P3: Mahasiswa akses /admin/rekap ===" -ForegroundColor Green
try { Invoke-RestMethod -Uri "$BASE/admin/rekap" -Headers @{Authorization = "Bearer $TOKEN_MHS"} } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code -eq 403) { Write-Host "OK Mahasiswa akses admin -> 403" -ForegroundColor Green } else { Write-Host "FAIL Mahasiswa akses admin bukan 403 ($code)"; exit 1 } }

Write-Host ""
Write-Host "=== CHECK P3: Admin akses /admin/rekap ===" -ForegroundColor Green
try { $ADM_OK = Invoke-RestMethod -Uri "$BASE/admin/rekap" -Headers @{Authorization = "Bearer $TOKEN_ADM"}; Write-Host "OK Admin akses admin -> 200" -ForegroundColor Green } catch { Write-Host "FAIL Admin akses admin gagal"; exit 1 }

Write-Host ""
Write-Host "=== CHECK P3: Secret hygiene ===" -ForegroundColor Green
Set-Location (Split-Path $PSScriptRoot)
if (git ls-files --error-unmatch backend/.env 2>$null) { Write-Host "FAIL BAHAYA: .env terlacak"; exit 1 } else { Write-Host "OK AMAN: .env tidak terlacak" -ForegroundColor Green }

Write-Host ""
Write-Host "=== SEMUA CHECK LULUS ===" -ForegroundColor Green