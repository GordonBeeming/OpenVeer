# DEV: .\deploy.ps1 -ResourceGroupName "dev-openveer-rg" -Location "westeurope" -Environment "dev"
[CmdletBinding()]
param (
    [Parameter()]
    [string]$ResourceGroupName,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$Environment
)

Write-Host @"

👀 $ResourceGroupName

"@

az group create --resource-group $ResourceGroupName --location $Location

Write-Host @"

👀 Application Insights

"@

az deployment group create --resource-group $ResourceGroupName --template-file "application-insights.bicep" --parameters environment=$Environment
