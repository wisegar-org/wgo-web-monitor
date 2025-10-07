# Script to install Website Monitor Service
# Must be run as Administrator

Write-Host "Installing Website Monitor Service..." -ForegroundColor Green
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$serviceName = "Website Monitor"
$servicePath = "C:\Users\ALIENWARE\Desktop\FREELANCER\.NET-DESKTOP\wgo-website-monitor-service\publish\WebsiteMonitorService.exe"

try {
    # Create the service
    Write-Host "Creating the service..." -ForegroundColor Yellow
    $result = sc.exe create $serviceName binPath=$servicePath DisplayName="Website Monitor Service" description="Service that monitors websites and sends alert emails"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Service created successfully" -ForegroundColor Green
        Write-Host ""
        
        # Start the service
        Write-Host "Starting the service..." -ForegroundColor Yellow
        $startResult = sc.exe start $serviceName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Service started successfully" -ForegroundColor Green
            Write-Host ""
            Write-Host "The Website Monitor service is now running in the background." -ForegroundColor Green
            Write-Host ""
            Write-Host "Useful commands:" -ForegroundColor Cyan
            Write-Host "- Check status: sc.exe query `"Website Monitor`"" -ForegroundColor White
            Write-Host "- Stop: sc.exe stop `"Website Monitor`"" -ForegroundColor White
            Write-Host "- Delete: sc.exe delete `"Website Monitor`"" -ForegroundColor White
            Write-Host ""
            Write-Host "Logs are located in: publish\Logs\" -ForegroundColor Cyan
        }
        else {
            Write-Host "✗ Error starting the service" -ForegroundColor Red
            Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    }
    else {
        Write-Host "✗ Error creating the service" -ForegroundColor Red
        Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue"