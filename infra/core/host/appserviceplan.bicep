metadata description = 'Creates an Azure App Service plan.'
param name string
param location string = resourceGroup().location
param tags object = {}

param sku object

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: 'linux'
  properties: {
    perSiteScaling: true
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
