$serviceName = "Wisegar.Monitor"
$serviceDisplayName = "Wisegar Monitor Service"
$serviceDescription = "Service that monitors websites and sends alert emails"
$exePath = ".\publish\Wisegar.Monitor.exe"

# Check for admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Output result
if (!$isAdmin) {
    Write-Host "PowerShell MOST be running as Administrator."
    return
}

New-Service -Name $serviceName `
    -BinaryPathName $exePath `
    -DisplayName $serviceDisplayName `
    -Description $serviceDescription `
    -StartupType Automatic

Start-Service -Name $serviceName

Remove-Service -Name $serviceName