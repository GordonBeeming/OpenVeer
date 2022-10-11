# DEV: .\deploy.ps1 -ResourceGroupName "dev-openveer-rg" -Location "westeurope" -Environment "dev"
[CmdletBinding()]
param (
    [Parameter()]
    [string]$ResourceGroupName,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$Environment,
    [Parameter()]
    [securestring]$SqlAdminPassword,
    [Parameter()]
    [switch]$AppRegistration
)

$CurrentAccount = az account show | Out-string | ConvertFrom-Json
$SubscriptionId = $CurrentAccount.id

Write-Host @"

👀 Create $ResourceGroupName

"@

az group create --resource-group $ResourceGroupName --location $Location

if ($AppRegistration) {
    $App = az ad app create --display-name "OpenVeer-$($Environment)" | Out-string | ConvertFrom-Json
    $ServicePrinciple = az ad sp create --id $App.appId | Out-string | ConvertFrom-Json
    $RoleAssignment = az role assignment create --role contributor --subscription $SubscriptionId --assignee-object-id $ServicePrinciple.Id --assignee-principal-type ServicePrincipal --scope "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)"
    $Subject = "repo:DevStarOps/OpenVeer:environment:$($Environment):ref:refs/heads/main"
    if ($Environment -ne "prod") {
        $Subject = "repo:DevStarOps/OpenVeer:environment:$($Environment)"
    }
    $Credential = @{
        "name"="GitHub"
        "issuer"="https://token.actions.githubusercontent.com"
        "subject"="$($Subject)"
        "description"="Deployments for DevStarOps/OpenVeer"
        "audiences"=@("api://AzureADTokenExchange")
    }
    $TempBodyFile = "$([System.IO.Path]::GetTempFileName()).json"
    Set-Content -Path $TempBodyFile -Value ($Credential | ConvertTo-Json) -Encoding utf8
    $federatedCredential = az ad app federated-credential create --id $App.Id --parameters $TempBodyFile
    Remove-Item -LiteralPath $TempBodyFile
}

Write-Host @"

👀 Deploy Core App

"@

az deployment group create --resource-group $ResourceGroupName --template-file "core-app.bicep" --parameters "environments/core-app-$($Environment).json" sqlAdministratorLoginPassword=$SqlAdminPassword

Write-Host @"

👀 Remove extra resources

"@

az deployment group create --force "core-app.bicep" --resource-group $ResourceGroupName --mode Complete



$MyJsonHashTable = @{
    'MyList' = @{
      'Item1' = @{
        'Name' = 'AMD Ryzen 5 3600x'
        'Type' = 'CPU'
        'Price' = '$69.99'
        'Where' = 'Amazon.com'
      }
    }
  }
  
  $MyJsonVariable = $MyJsonHashTable | ConvertTo-Json