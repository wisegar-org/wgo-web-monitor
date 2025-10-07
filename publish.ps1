# Define the publish folder path
$publishPath = "./publish/"
$projectPath = "./Wisegar.Monitor.csproj"

# Remove the publish folder recursively and quietly
Write-Host "Cleaning publish path..."
Remove-Item -Path $publishPath -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cleaning publish path...OK"

# Build the project in Release mode
Write-Host "Building project..."
dotnet build $projectPath -c Release
Write-Host "Building project...OK"

# Publish as a self-contained app for Windows x64
$windowsPath = Join-Path $publishPath "windows"
Write-Host "Publishing to $windowsPath..."
dotnet publish $projectPath -c Release -r win-x64 --self-contained true -o $windowsPath
Write-Host "Publishing to $windowsPath...OK"

# Publish as a self-contained app for Linux x64
$linuxpath = Join-Path $publishPath "linux"
Write-Host "Publishing to $linuxpath..."
dotnet publish $projectPath -c Release -r linux-x64 --self-contained true -o $linuxpath
Write-Host "Publishing to $linuxpath...OK"
