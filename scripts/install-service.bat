@echo off
echo Installing Website Monitor Service...
echo.

REM Create the service
sc.exe create "Website Monitor" binPath="C:\Users\ALIENWARE\Desktop\FREELANCER\.NET-DESKTOP\wgo-website-monitor-service\publish\WebsiteMonitorService.exe" DisplayName="Website Monitor Service" description="Service that monitors websites and sends alert emails"

if %ERRORLEVEL% EQU 0 (
    echo ✓ Service created successfully
    echo.
    
    REM Start the service
    echo Starting the service...
    sc.exe start "Website Monitor"
    
    if %ERRORLEVEL% EQU 0 (
        echo ✓ Service started successfully
        echo.
        echo The Website Monitor service is now running in the background.
        echo To check status: sc.exe query "Website Monitor"
        echo To stop: sc.exe stop "Website Monitor"
        echo To delete: sc.exe delete "Website Monitor"
    ) else (
        echo ✗ Error starting the service
    )
) else (
    echo ✗ Error creating the service
    echo Make sure to run this script as Administrator
)

echo.
pause