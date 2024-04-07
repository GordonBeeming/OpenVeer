targetScope = 'resourceGroup'
param location string = resourceGroup().location

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string
param projectName string = 'openveer'

@minLength(1)
@maxLength(7)
@description('The base address prefix. e.g.: 10.1')
param addressPrefix string
var webSitesAppServiceSubnetNumber = 1
var databaseSubnetNumber = 2
var keyVaultSubnetNumber = 3
var storageSubnetNumber = 4

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
  'project': projectName
}

// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower('${projectName}-${environmentName}')
var resourceTokenNoDash = replace(resourceToken, '-', '')

// networking
var vNetName = '${abbrs.networkVirtualNetworks}${resourceToken}'
var webSitesAppServiceSubnetName = '${abbrs.networkVirtualNetworksSubnets}${abbrs.webSitesAppService}${resourceToken}'
var databaseSubnetName = '${abbrs.networkVirtualNetworksSubnets}${abbrs.sqlServersDatabases}${resourceToken}'
var keyVaultSubnetName = '${abbrs.networkVirtualNetworksSubnets}${abbrs.keyVaultVaults}${resourceToken}'
var storageSubnetName = '${abbrs.networkVirtualNetworksSubnets}${abbrs.storageStorageAccounts}-${resourceToken}'

// monitoring
var applicationInsightsName = '${abbrs.insightsComponents}${resourceToken}'
var logAnalyticsName = '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
var applicationInsightsDashboardName = '${abbrs.portalDashboards}${resourceToken}'

// storage
var storageName = '${abbrs.storageStorageAccounts}${resourceTokenNoDash}'

// keyvault
var keyVaultName = '${abbrs.keyVaultVaults}${resourceToken}'

// app service
var appServicePlanName = '${abbrs.webSitesAppService}${resourceToken}'
var appServicePlanSku = 'B3'
var appRedirectName = '${abbrs.webSitesAppService}redirect-${resourceToken}'
var appRedirectLinuxFxVersion = 'DOCKER|ghcr.io/gordonbeeming/openveerredirect:main'

// resources
module network './app/network.bicep' = {
  name: '${deployment().name}-network'
  params: {
    location: location
    tags: tags
    vNetName: vNetName
    webSitesAppServiceSubnetName: webSitesAppServiceSubnetName
    databaseSubnetName: databaseSubnetName
    keyVaultSubnetName: keyVaultSubnetName
    storageSubnetName: storageSubnetName
    addressPrefix: addressPrefix
    webSitesAppServiceSubnetNumber: webSitesAppServiceSubnetNumber
    databaseSubnetNumber: databaseSubnetNumber
    keyVaultSubnetNumber: keyVaultSubnetNumber
    storageSubnetNumber: storageSubnetNumber
  }
}

module monitoring './core/monitor/monitoring.bicep' = {
  name: '${deployment().name}-monitoring'
  params: {
    location: location
    tags: tags
    applicationInsightsName: applicationInsightsName
    logAnalyticsName: logAnalyticsName
    applicationInsightsDashboardName: applicationInsightsDashboardName
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: '${deployment().name}-storage'
  params: {
    location: location
    tags: tags
    name: storageName
    storageSubnetId: network.outputs.storageSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

module keyvault 'core/security/keyvault.bicep' = {
  name: '${deployment().name}-keyvault'
  params: {
    location: location
    tags: tags
    name: keyVaultName
    keyvaultSubnetId: network.outputs.keyVaultSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

module appService 'core/host/appserviceplan.bicep' = {
  name: '${deployment().name}-appservice'
  params: {
    location: location
    tags: tags
    name: appServicePlanName
    sku: {
      name: appServicePlanSku
    }
  }
}

module appRedirect 'core/host/appservice.bicep' = {
  name: '${deployment().name}-app-redirect'
  params: {
    name: appRedirectName
    location: location
    tags: tags
    abbrs: abbrs
    webAppVNetName: vNetName
    webAppSubnetId: network.outputs.webSitesAppServiceSubnetId
    applicationInsightsName: applicationInsightsName
    appServicePlanId: appService.outputs.id
    keyVaultName: keyVaultName
    linuxFxVersion: appRedirectLinuxFxVersion
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    appSettings: {
      ASPNETCORE_ENVIRONMENT: 'Production'
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      DOCKER_REGISTRY_SERVER_URL: 'https://ghcr.io'
    }
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
