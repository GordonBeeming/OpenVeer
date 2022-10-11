@description('Which environment is this')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string

@description('Location for all resources.')
param location string = resourceGroup().location

resource deployUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'openveer-deploy-${environment}'
  location: location
}

