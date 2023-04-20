param AutomationAccountName string
param Location string
param Tags object


resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: AutomationAccountName
  location: Location
  tags: Tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
  }
}
