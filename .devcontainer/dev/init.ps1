#requires -PSEdition Core
# Additional steps to initialize the development container

# Install sqlserver module so we can use 'Invoke-Sqlcmd'
Install-Module sqlserver -Confirm:$False  -Force

# Invoke-Sqlcmd -ServerInstance "openveer_db,1433" -Username SA -Password P@ssw0rd12345 -Query "SELECT * FROM sys.databases";

# Create new database
# Source for the retry logic:
# https://stackoverflow.com/a/47712807/411428
$attempts = 20
$sleepInSeconds = 3
do {
  try {
    Invoke-Sqlcmd -ServerInstance "openveer_db,1433" -Username SA -Password "P@ssw0rd12345" -Query "CREATE DATABASE [OpenVeer]";
    Write-Host "Database created successfully."
    break;
  }
  catch [Exception] {
    #Write-Host $_.Exception.Message
    Write-Host "Retrying..."
  }            
  $attempts--
  if ($attempts -gt 0) { Start-Sleep $sleepInSeconds }
} while ($attempts -gt 0)

. /app/.devcontainer/dev/build.ps1
. /app/.devcontainer/dev/local-publish.ps1
# Invoke-Sqlcmd -ServerInstance "openveer_db,1433" -Username SA -Password "P@ssw0rd12345" -InputFile "/app/.devcontainer/dev/init.sql";

# dotnet new --install MSBuild.Sdk.SqlProj.Templates
