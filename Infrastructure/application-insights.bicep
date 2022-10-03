param location string = resourceGroup().location
param environment string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'openveer-${environment}'
  location: location
  kind: 'web'  
  properties: {
    Application_Type: 'web'
  }
}
