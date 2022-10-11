@description('Which environment is this')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'B1'

@description('The admin user of the SQL Server')
param sqlAdministratorLogin string

@description('The password of the admin user of the SQL Server')
@secure()
param sqlAdministratorLoginPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

var hostingPlanName = 'openveer-${environment}'
var websiteNameRedirectEdge = 'openveer-redirectedge-${environment}'
var websiteNameFrontEnd = 'openveer-frontend-${environment}'
var websiteNameApi = 'openveer-api-${environment}'
var sqlserverName = 'openveer-${environment}'
var databaseName = 'openveer'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'openveer-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
          delegations: [
            {
              name: 'serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }        
      }      
    ]        
  }  
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlserverName
  location: location
  tags: {
    displayName: 'SQL Server'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess:'Enabled'    
  }
}

resource openveerVnetRule 'Microsoft.Sql/servers/virtualNetworkRules@2022-02-01-preview' = {
  name: 'openveer-vnet-rule'
  parent: sqlServer
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: {
    displayName: 'Database'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824    
  }
}

resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  tags: {
  }
  sku: {
    name: skuName
  }
  properties:{
    reserved:true
  }
}

resource redirectEdge 'Microsoft.Web/sites@2020-12-01' = {
  name: websiteNameRedirectEdge
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'OpenVeer Redirect Edge'
  }
  properties: {
    siteConfig: {
      appSettings: []
      netFrameworkVersion: '7.0'
      alwaysOn: true
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
    httpsOnly: true
  }
}

resource webSiteConnectionStringsRedirectEdge 'Microsoft.Web/sites/config@2020-12-01' = {
  parent: redirectEdge
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      value: 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};User Id=${sqlAdministratorLogin}@${sqlServer.properties.fullyQualifiedDomainName};Password=${sqlAdministratorLoginPassword};'
      type: 'SQLAzure'
    }
  }
}

resource frontEnd 'Microsoft.Web/sites@2020-12-01' = {
  name: websiteNameFrontEnd
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'OpenVeer Front End'
  }
  properties: {
    siteConfig: {
      appSettings: []
      netFrameworkVersion: '7.0'
      alwaysOn: true
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
    httpsOnly: true
  }
}

resource api 'Microsoft.Web/sites@2020-12-01' = {
  name: websiteNameApi
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'OpenVeer API'
  }
  properties: {
    siteConfig: {
      appSettings: []
      netFrameworkVersion: '7.0'
      alwaysOn: true
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
    httpsOnly: true
  }
}

resource webSiteConnectionStringsApi 'Microsoft.Web/sites/config@2020-12-01' = {
  parent: api
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      value: 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};User Id=${sqlAdministratorLogin}@${sqlServer.properties.fullyQualifiedDomainName};Password=${sqlAdministratorLoginPassword};'
      type: 'SQLAzure'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'openveer-${environment}'
  location: location
  tags: {
    'hidden-link:${redirectEdge.id}': 'Resource'
    'hidden-link:${frontEnd.id}': 'Resource'
    'hidden-link:${api.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  kind: 'web'  
  properties: {
    Application_Type: 'web'
  }
}
