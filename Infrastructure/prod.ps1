# .\prod.ps1 -SqlAdminPassword (ConvertTo-SecureString -string "P@ssw0rd1234" -AsPlainText -Force) -AppRegistration
[CmdletBinding()]
param (
    [Parameter()]
    [securestring]$SqlAdminPassword,
    [Parameter()]
    [switch]$AppRegistration
)

.\deploy.ps1 -ResourceGroupName "prod-openveer-rg" -Location "westeurope" -Environment "prod" -SqlAdminPassword $SqlAdminPassword -AppRegistration:$AppRegistration
