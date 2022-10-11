# .\dev.ps1 -SqlAdminPassword (ConvertTo-SecureString -string "P@ssw0rd1234" -AsPlainText -Force)
[CmdletBinding()]
param (
    [Parameter()]
    [securestring]$SqlAdminPassword
)

.\deploy.ps1 -ResourceGroupName "dev-openveer-rg" -Location "westeurope" -Environment "dev" -SqlAdminPassword $SqlAdminPassword
