metadata description = 'Creates an Azure SQL Server instance.'
param name string
param location string = resourceGroup().location
param tags object = {}
param abbrs object = {}

param databaseSubnetId string
param logAnalyticsWorkspaceId string

param skuName string = 'Basic'
param skuCapacity int = 5
param databaseName string
param keyVaultName string
param sqlAdmin string = 'sqlAdmin'
param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'

@secure()
param sqlAdminPassword string

// networking
var virtualNetworkConnectionName = '${abbrs.networkConnections}${name}'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Zone'
    isLedgerOn: false
    preferredEnclaveType: 'VBS'
    availabilityZone: 'NoPreference'
  }
}

resource virtualNetworkRule 'Microsoft.Sql/servers/virtualNetworkRules@2023-05-01-preview' = {
  parent: sqlServer
  name: virtualNetworkConnectionName
  properties: {
    virtualNetworkSubnetId: databaseSubnetId
    ignoreMissingVnetServiceEndpoint: false
  }
}

// resource backupLongTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2023-05-01-preview' = {
//   parent: sqlDatabase
//   name: 'default'
//   properties: {
//     makeBackupsImmutable: true
//     backupStorageAccessTier: 'Hot'
//     weeklyRetention: 'PT0S'
//     monthlyRetention: 'PT0S'
//     yearlyRetention: 'PT0S'
//     weekOfYear: 0
//   }
// }

resource backupShortTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: 14
    diffBackupIntervalInHours: 24
  }
}

resource diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sqlDatabase
  name: '${sqlServer.name}-${sqlDatabase.name}-diagnostic-settings'
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
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
  }
}

resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
}

resource sqlAzureConnectionStringSercret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: connectionStringKey
  properties: {
    value: '${connectionString}; Password=${sqlAdminPassword}'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var connectionString = 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Database=${sqlDatabase.name}; User=${sqlAdmin}'
output connectionStringKey string = connectionStringKey
output connectionString string = '@Microsoft.KeyVault(SecretUri=${sqlAzureConnectionStringSercret.properties.secretUri})'
output databaseName string = sqlDatabase.name
