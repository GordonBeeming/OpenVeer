#requires -PSEdition Core

Install-Module sqlserver -Confirm:$False  -Force

$attempts = 20
$sleepInSeconds = 3
do {
  try {
    if (Test-Path "/app/openveer_db/OpenVeer.mdf") {
      Invoke-Sqlcmd -ServerInstance "openveer_db,1433" -Username SA -Password "P@ssw0rd12345" -Query @"
    CREATE DATABASE [OpenVeer]   
    ON (FILENAME = '/db/OpenVeer.mdf'),   
        (FILENAME = '/db/OpenVeer.ldf')   
    FOR ATTACH;  
"@;
      Write-Host "Database attached successfully."
    }
    else {
      Invoke-Sqlcmd -ServerInstance "openveer_db,1433" -Username SA -Password "P@ssw0rd12345" -Query @"
    CREATE DATABASE [OpenVeer]
    ON
    ( NAME = Solutions_dat,  
        FILENAME = '/db/OpenVeer.mdf',
        SIZE = 10MB,
        MAXSIZE = 50MB,
        FILEGROWTH = 5MB )  
    LOG ON
    ( NAME = Solutions_log,  
        FILENAME = '/db/OpenVeer.ldf',
        SIZE = 5MB,
        MAXSIZE = 25MB,
        FILEGROWTH = 5MB );
    GO
"@;
      Write-Host "Database created successfully."
    }
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
