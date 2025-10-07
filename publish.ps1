# Define the publish folder path
$publishPath = "./publish/"

Write-Host "Publishing to $publishPath..."

# Remove the publish folder recursively and quietly
Remove-Item -Path $publishPath -Recurse -Force -ErrorAction SilentlyContinue

# Build the project in Release mode
dotnet build "./Wisegar.Monitor.csproj" -c Release

# Publish as a self-contained app for Windows x64
dotnet publish "./Wisegar.Monitor.csproj" -c Release -r win-x64 --self-contained true -o $publishPath
