@echo off
echo Instalando Website Monitor Service...
echo.

REM Crear el servicio
sc.exe create "Website Monitor" binPath="C:\Users\ALIENWARE\Desktop\FREELANCER\.NET-DESKTOP\wgo-website-monitor-service\publish\WebsiteMonitorService.exe" DisplayName="Website Monitor Service" description="Servicio que monitorea sitios web y envia alertas por email"

if %ERRORLEVEL% EQU 0 (
    echo ✓ Servicio creado exitosamente
    echo.
    
    REM Iniciar el servicio
    echo Iniciando el servicio...
    sc.exe start "Website Monitor"
    
    if %ERRORLEVEL% EQU 0 (
        echo ✓ Servicio iniciado exitosamente
        echo.
        echo El servicio Website Monitor está ahora ejecutándose en segundo plano.
        echo Para verificar el estado: sc.exe query "Website Monitor"
        echo Para detener: sc.exe stop "Website Monitor"
        echo Para eliminar: sc.exe delete "Website Monitor"
    ) else (
        echo ✗ Error al iniciar el servicio
    )
) else (
    echo ✗ Error al crear el servicio
    echo Asegúrate de ejecutar este script como Administrador
)

echo.
pause