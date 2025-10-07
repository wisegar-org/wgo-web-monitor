$serviceName = "DocVaultService"
$serviceDisplayName = "DocVault Document Service"
$serviceDescription = "Secure document management platform aligned with Swiss DSG/LPD"
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