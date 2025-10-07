# Script para instalar Website Monitor Service
# Debe ejecutarse como Administrador

Write-Host "Instalando Website Monitor Service..." -ForegroundColor Green
Write-Host ""

# Verificar si se está ejecutando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Write-Host "Haz clic derecho en PowerShell y selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

$serviceName = "Website Monitor"
$servicePath = "C:\Users\ALIENWARE\Desktop\FREELANCER\.NET-DESKTOP\wgo-website-monitor-service\publish\WebsiteMonitorService.exe"

try {
    # Crear el servicio
    Write-Host "Creando el servicio..." -ForegroundColor Yellow
    $result = sc.exe create $serviceName binPath=$servicePath DisplayName="Website Monitor Service" description="Servicio que monitorea sitios web y envia alertas por email"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Servicio creado exitosamente" -ForegroundColor Green
        Write-Host ""
        
        # Iniciar el servicio
        Write-Host "Iniciando el servicio..." -ForegroundColor Yellow
        $startResult = sc.exe start $serviceName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Servicio iniciado exitosamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "El servicio Website Monitor está ahora ejecutándose en segundo plano." -ForegroundColor Green
            Write-Host ""
            Write-Host "Comandos útiles:" -ForegroundColor Cyan
            Write-Host "- Verificar estado: sc.exe query `"Website Monitor`"" -ForegroundColor White
            Write-Host "- Detener: sc.exe stop `"Website Monitor`"" -ForegroundColor White
            Write-Host "- Eliminar: sc.exe delete `"Website Monitor`"" -ForegroundColor White
            Write-Host ""
            Write-Host "Los logs se guardan en: publish\Logs\" -ForegroundColor Cyan
        } else {
            Write-Host "✗ Error al iniciar el servicio" -ForegroundColor Red
            Write-Host "Código de error: $LASTEXITCODE" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Error al crear el servicio" -ForegroundColor Red
        Write-Host "Código de error: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Presiona Enter para continuar"