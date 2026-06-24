$ErrorActionPreference = "Stop"

Write-Host "=== Inyección de Seed en MongoDB ===" -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "seed.js"

if (-not (Test-Path $scriptPath)) {
    Write-Host "Error: No se encontró seed.js en $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Leyendo configuración desde .env..." -ForegroundColor Gray
Write-Host "Ejecutando seed..." -ForegroundColor Green
node $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Seed completado exitosamente" -ForegroundColor Green
} else {
    Write-Host "Error al ejecutar el seed" -ForegroundColor Red
    exit 1
}
