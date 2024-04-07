metadata description = 'Creates an Azure App Service in an existing Azure App Service plan.'
param name string
param location string = resourceGroup().location
param tags object = {}
param abbrs object = {}

// Reference Properties
param webAppVNetName string
param webAppSubnetId string
param applicationInsightsName string = ''
param appServicePlanId string
param keyVaultName string = ''
param logAnalyticsWorkspaceId string

// Microsoft.Web/sites/config
param allowedOrigins array = []
param appCommandLine string = ''
@secure()
param appSettings object = {}
param functionAppScaleLimit int = 0
param minimumElasticInstanceCount int = 0
param linuxFxVersion string
param numberOfWorkers int = 1
param healthCheckPath string = ''

// identity
var managedIdentityName = 'id-${name}'

var virtualNetworkConnectionName = '${abbrs.networkConnections}${name}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${name}.azurewebsites.net'
        sslState: 'SniEnabled'
        hostType: 'Standard'
      }
      {
        name: '${name}.scm.azurewebsites.net'
        sslState: 'SniEnabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanId
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: numberOfWorkers
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: functionAppScaleLimit
      minimumElasticInstanceCount: minimumElasticInstanceCount
      appCommandLine: appCommandLine
      healthCheckPath: healthCheckPath
      cors: {
        allowedOrigins: union(['https://portal.azure.com', 'https://ms.portal.azure.com'], allowedOrigins)
      }
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: false
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: false
      scmType: 'None'
      use32BitWorkerProcess: false
      webSocketsEnabled: false
      managedPipelineMode: 'Integrated'
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
      ]
      loadBalancing: 'LeastRequests'
      experiments: {
        rampUpRules: []
      }
      autoHealEnabled: false
      vnetName: webAppVNetName
      vnetRouteAllEnabled: true
      vnetPrivatePortsCount: 0
      publicNetworkAccess: 'Enabled'
      localMySqlEnabled: false
      ipSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Allow'
          priority: 2147483647
          name: 'Allow all'
          description: 'Allow all access'
        }
      ]
      scmIpSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Deny'
          priority: 2147483647
          name: 'Deny all'
        }
      ]
      scmIpSecurityRestrictionsUseMain: false
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'Disabled'
      preWarmedInstanceCount: 0
      functionsRuntimeScaleMonitoringEnabled: false
      azureStorageAccounts: {}
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: webAppSubnetId
    keyVaultReferenceIdentity: managedIdentity.id
  }

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }
}

resource diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appService
  name: '${appService.name}-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-01-01' = {
  parent: appService
  name: virtualNetworkConnectionName
  properties: {
    vnetResourceId: webAppSubnetId
    isSwift: true
  }
}

// Updates to the single Microsoft.sites/web/config resources that need to be performed sequentially
// sites/web/config 'appsettings'
module configAppSettings 'appservice-appsettings.bicep' = {
  name: '${deployment().name}-${name}-appSettings'
  params: {
    name: appService.name
    appSettings: union(
      appSettings,
      {
        name: 'AZURE_CLIENT_ID'
        value: managedIdentity.properties.clientId
      },
      !empty(applicationInsightsName)
        ? { APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString }
        : {},
      !empty(keyVaultName) ? { AZURE_KEY_VAULT_ENDPOINT: keyVault.properties.vaultUri } : {}
    )
  }
}

// sites/web/config 'logs'
resource configLogs 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'logs'
  parent: appService
  properties: {
    applicationLogs: { fileSystem: { level: 'Verbose' } }
    detailedErrorMessages: { enabled: true }
    failedRequestsTracing: { enabled: true }
    httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
  }
  dependsOn: [configAppSettings]
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing =
  if (!(empty(keyVaultName))) {
    name: keyVaultName
  }

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing =
  if (!empty(applicationInsightsName)) {
    name: applicationInsightsName
  }

output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityId string = managedIdentity.id
output managedIdentityName string = managedIdentity.name
