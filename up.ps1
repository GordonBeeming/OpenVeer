
Param(
  [switch]$skipDeploy = $false
)

Write-Host "🚢 Starting Docker Compose"
docker compose up -d
if (-not $skipDeploy)
{
  Write-Host "⚙️ Restore dotnet tools"
  dotnet tool restore

  Set-Location $($Script:MyInvocation.MyCommand.Path | Split-Path)

  $windows = $env:OS -eq "Windows_NT"
  if (-not $windows) {
    Write-Host "⚙️ Building OpenVeer Database AppDbContext Bundle"
    dotnet restore --runtime 'linux-x64'
    Set-Location ./src/
    dotnet ef migrations bundle --project 'Data' --startup-project 'Api' --force --context AppDbContext --output AppDbContextEfBundle

    Write-Host "🚀 Deploying OpenVeer Database AppDbContext Bundle"
    . ./AppDbContextEfBundle --connection "Server=.,1800;Database=OpenVeer;User Id=sa;Password=Password!@2;MultipleActiveResultSets=true;TrustServerCertificate=True;" 
  }
  else {
    Write-Host "⚙️ Building OpenVeer Database AppDbContext Bundle"
    dotnet restore --runtime 'win-x64'
    Set-Location .\src\
    dotnet ef migrations bundle --project 'Data' --startup-project 'Api' --force --context AppDbContext --output AppDbContextEfBundle.exe

    Write-Host "🚀 Deploying OpenVeer Database AppDbContext Bundle"
    . .\AppDbContextEfBundle.exe --connection "Server=.,1800;Database=OpenVeer;User Id=sa;Password=Password!@2;MultipleActiveResultSets=true;TrustServerCertificate=True;"
  }

  Set-Location $($Script:MyInvocation.MyCommand.Path | Split-Path)
}