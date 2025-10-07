@echo off
echo Uninstalling Website Monitor Service...
echo.

REM Stop the service if it is running
echo Stopping the service...
sc.exe stop "Website Monitor"

REM Delete the service
echo Deleting the service...
sc.exe delete "Website Monitor"

if %ERRORLEVEL% EQU 0 (
    echo ✓ Service deleted successfully
) else (
    echo ✗ Error deleting the service or the service did not exist
)

echo.
pause