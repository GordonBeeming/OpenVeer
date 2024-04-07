param location string = resourceGroup().location
param tags object = {}

param addressPrefix string
param webSitesAppServiceSubnetNumber int
param databaseSubnetNumber int
param keyVaultSubnetNumber int
param storageSubnetNumber int

param vNetName string
param webSitesAppServiceSubnetName string
param databaseSubnetName string
param keyVaultSubnetName string
param storageSubnetName string

resource vNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vNetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: ['${addressPrefix}.0.0/16']
    }
    // encryption is not supported in Australia yet
    // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#availability
    // encryption: {
    //   enabled: true
    //   enforcement: 'AllowUnencrypted'
    // }
    subnets: [
      {
        name: webSitesAppServiceSubnetName
        properties: {
          addressPrefix: '${addressPrefix}.${webSitesAppServiceSubnetNumber}.0/24'
          serviceEndpoints: []
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
              type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: databaseSubnetName
        properties: {
          addressPrefix: '${addressPrefix}.${databaseSubnetNumber}.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: keyVaultSubnetName
        properties: {
          addressPrefix: '${addressPrefix}.${keyVaultSubnetNumber}.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: '${addressPrefix}.${storageSubnetNumber}.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false // https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview
  }
}

resource webSitesAppServiceSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: webSitesAppServiceSubnetName
  parent: vNet
}

resource databaseSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: databaseSubnetName
  parent: vNet
}

resource keyVaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: keyVaultSubnetName
  parent: vNet
}

resource storageSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: storageSubnetName
  parent: vNet
}

output vnetId string = vNet.id
output webSitesAppServiceSubnetId string = webSitesAppServiceSubnet.id
output databaseSubnetId string = databaseSubnet.id
output keyVaultSubnetId string = keyVaultSubnet.id
output storageSubnetId string = storageSubnet.id
