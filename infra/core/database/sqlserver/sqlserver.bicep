metadata description = 'Creates an Azure SQL Server instance.'
param name string
param location string = resourceGroup().location
param tags object = {}
param abbrs object = {}

param databaseSubnetId string
param logAnalyticsWorkspaceId string

param skuName string = 'Basic'
param skuCapacity int = 5
param appUser string = 'appUser'
param databaseName string
param keyVaultName string
param sqlAdmin string = 'sqlAdmin'
param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'

@secure()
param sqlAdminPassword string
@secure()
param appUserPassword string

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

resource sqlDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${name}-deployment-script'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.37.0'
    retentionInterval: 'PT1H' // Retain the script resource for 1 hour after it ends running
    timeout: 'PT5M' // Five minutes
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'APPUSERNAME'
        value: appUser
      }
      {
        name: 'APPUSERPASSWORD'
        secureValue: appUserPassword
      }
      {
        name: 'DBNAME'
        value: databaseName
      }
      {
        name: 'DBSERVER'
        value: sqlServer.properties.fullyQualifiedDomainName
      }
      {
        name: 'SQLCMDPASSWORD'
        secureValue: sqlAdminPassword
      }
      {
        name: 'SQLADMIN'
        value: sqlAdmin
      }
    ]

    scriptContent: '''
wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

cat <<SCRIPT_END > ./initDb.sql
drop user if exists ${APPUSERNAME}
go
create user ${APPUSERNAME} with password = '${APPUSERPASSWORD}'
go
alter role db_owner add member ${APPUSERNAME}
go
SCRIPT_END

./sqlcmd -S ${DBSERVER} -d ${DBNAME} -U ${SQLADMIN} -i ./initDb.sql
    '''
  }
}

resource encryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2023-05-01-preview' = {
  parent: sqlServer
  name: 'current'
  properties: {
    serverKeyName: 'ServiceManaged'
    serverKeyType: 'ServiceManaged'
    autoRotationEnabled: false
  }
}

resource sqlServerKey 'Microsoft.Sql/servers/keys@2023-05-01-preview' = {
  parent: sqlServer
  name: 'ServiceManaged'
  properties: {
    serverKeyType: 'ServiceManaged'
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

resource transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'Current'
  properties: {
    state: 'Enabled'
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

resource appUserPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'appUserPassword'
  properties: {
    value: appUserPassword
  }
}

resource sqlAzureConnectionStringSercret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: connectionStringKey
  properties: {
    value: '${connectionString}; Password=${appUserPassword}'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var connectionString = 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Database=${sqlDatabase.name}; User=${appUser}'
output connectionStringKey string = connectionStringKey
output connectionString string = '@Microsoft.KeyVault(SecretUri=${sqlAzureConnectionStringSercret.properties.secretUri})'
output databaseName string = sqlDatabase.name
