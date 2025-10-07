@echo off
echo Desinstalando Website Monitor Service...
echo.

REM Detener el servicio si está ejecutándose
echo Deteniendo el servicio...
sc.exe stop "Website Monitor"

REM Eliminar el servicio
echo Eliminando el servicio...
sc.exe delete "Website Monitor"

if %ERRORLEVEL% EQU 0 (
    echo ✓ Servicio eliminado exitosamente
) else (
    echo ✗ Error al eliminar el servicio o el servicio no existía
)

echo.
pause