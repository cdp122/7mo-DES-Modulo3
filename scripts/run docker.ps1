# Iniciar-DB.ps1
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Configurando MongoDB Local con Transacciones" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Verificar si Docker está corriendo
$dockerCheck = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerCheck) {
    Write-Host "[X] Docker Desktop no se está ejecutando. Por favor, ábrelo primero." -ForegroundColor Red
    Exit
}

# 2. Levantar el contenedor de Docker Compose
Write-Host "`n[1/3] Levantando contenedor de MongoDB..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error al ejecutar docker-compose. Verifica que tienes Docker instalado." -ForegroundColor Red
    Exit
}

# 3. Esperar a que el Replica Set esté listo
Write-Host "[2/3] Esperando a que MongoDB inicie el Replica Set..." -ForegroundColor Yellow
$retries = 10
$isReady = $false

for ($i = 1; $i -le $retries; $i++) {
    # Ejecuta un comando rápido en mongosh para ver si ya somos el nodo PRINCIPAL
    $status = docker exec mongo-local-tx mongosh --quiet --eval "try { db.hello().isWritablePrimary } catch(e) { false }" 2>$null
    
    if ($status.Trim() -eq "true") {
        $isReady = $true
        break
    }
    Start-Sleep -Seconds 3
    Write-Host "      Reintentando comprobación ($i/$retries)..." -ForegroundColor Gray
}

# 4. Resultado final
if ($isReady) {
    Write-Host "`n[3/3] ¡Todo listo! Base de datos configurada con éxito." -ForegroundColor Green
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host "Cadena de conexión para tu archivo .env:" -ForegroundColor White
    Write-Host "mongodb://localhost:27017/7mo_des_modulo3?replicaSet=rs0" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor Green
} else {
    Write-Host "`n[X] MongoDB tardó demasiado en responder. Revisa los logs con: docker logs mongo-local-tx" -ForegroundColor Red
}