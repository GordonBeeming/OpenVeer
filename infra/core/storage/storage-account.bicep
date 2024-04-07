metadata description = 'Creates an Azure storage account.'
param name string
param location string = resourceGroup().location
param tags object = {}
param storageSubnetId string
param logAnalyticsWorkspaceId string

@allowed([
  'Cool'
  'Hot'
  'Premium'
])
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param allowCrossTenantReplication bool = false
param allowSharedKeyAccess bool = false
param defaultToOAuthAuthentication bool = false
@allowed(['AzureDnsZone', 'Standard'])
param dnsEndpointType string = 'Standard'
param networkAcls object = {
  bypass: 'None'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: [
    {
      id: storageSubnetId
      action: 'Allow'
      state: 'Succeeded'
    }
  ]
}
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param sku object = { name: 'Standard_ZRS', tier: 'Standard' }

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: sku
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    dnsEndpointType: dnsEndpointType
    minimumTlsVersion: 'TLS1_2'
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
    immutableStorageWithVersioning: {
      enabled: true
    }
    encryption: {
      requireInfrastructureEncryption: true
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
        file: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storage
  name: '${storage.name}-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storage
  properties: {
    protocolSettings: {
      smb: {
        versions: 'SMB3.1.1;'
        authenticationMethods: 'Kerberos;'
        kerberosTicketEncryption: 'AES-256;'
        channelEncryption: 'AES-256-GCM;'
      }
    }
    shareDeleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource diagnosticsettings_fileServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fileServices
  name: '${fileServices.name}-diagnostic-settings'
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
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storage
  properties: {
    changeFeed: {
      enabled: true
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 14
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 14
    }
    isVersioningEnabled: true
  }
}

resource diagnosticsettings_blobServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: blobServices
  name: '${blobServices.name}-diagnostic-settings'
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
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storage
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource diagnosticsettings_queueServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: queueServices
  name: '${queueServices.name}-diagnostic-settings'
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
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storage
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource diagnosticsettings_tableServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: tableServices
  name: '${tableServices.name}-diagnostic-settings'
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
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output name string = storage.name
output primaryEndpoints object = storage.properties.primaryEndpoints
