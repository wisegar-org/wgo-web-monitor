@echo off
echo Verificando estado del Website Monitor Service...
echo.

sc.exe query "Website Monitor"

echo.
echo Para ver los logs del servicio, revisa la carpeta Logs\ en:
echo C:\Users\ALIENWARE\Desktop\FREELANCER\.NET-DESKTOP\wgo-website-monitor-service\publish\Logs\
echo.
pause