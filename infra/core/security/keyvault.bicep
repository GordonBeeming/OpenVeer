metadata description = 'Creates an Azure Key Vault.'
param name string
param location string = resourceGroup().location
param tags object = {}
param keyvaultSubnetId string
param logAnalyticsWorkspaceId string

param networkAcls object = {
  bypass: 'None'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: [
    {
      id: keyvaultSubnetId
      action: 'Allow'
      state: 'Succeeded'
    }
  ]
}

param principalId string = ''

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    accessPolicies: !empty(principalId)
      ? [
          {
            objectId: principalId
            permissions: { secrets: ['get', 'list'] }
            tenantId: subscription().tenantId
          }
        ]
      : []
    networkAcls: networkAcls
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    publicNetworkAccess: 'SecuredByPerimeter'
  }
}

resource diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: '${keyVault.name}-diagnostic-settings'
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

output endpoint string = keyVault.properties.vaultUri
output name string = keyVault.name
