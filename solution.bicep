param AutomationAccountName string
param BeginPeakTime string = '8:00'
param EndPeakTime string = '17:00'
param HostPoolName string
param HostPoolResourceGroupName string
param LimitSecondsToForceLogOffUser string = '0'
param Location string = resourceGroup().location
param LogAnalyticsWorkspaceResourceId string = ''
param MinimumNumberOfRdsh string = '0'
param SessionHostsResourceGroupName string
param SessionThresholdPerCPU string = '1'
param Tags object
param Timestamp string = utcNow('u')


var RoleAssignments = HostPoolResourceGroupName == SessionHostsResourceGroupName ? [
  HostPoolResourceGroupName
] : [
  HostPoolResourceGroupName
  SessionHostsResourceGroupName
]
var RunbookName = 'AvdAutoScale'
var TimeDifferences = {
  australiacentral: '+10:00'
  australiacentral2: '+10:00'
  australiaeast: '+10:00'
  australiasoutheast: '+10:00'
  brazilsouth: '-3:00'
  brazilsoutheast: '-3:00'
  canadacentral: '-5:00'
  canadaeast: '-5:00'
  centralindia: '+5:30'
  centralus: '-6:00'
  chinaeast: '+8:00'
  chinaeast2: '+8:00'
  chinanorth: '+8:00'
  chinanorth2: '+8:00'
  eastasia: '+8:00'
  eastus: '-5:00'
  eastus2: '-5:00'
  francecentral: '+1:00'
  francesouth: '+1:00'
  germanynorth: '+1:00'
  germanywestcentral: '+1:00'
  japaneast: '+9:00'
  japanwest: '+9:00'
  jioindiacentral: '+5:30'
  jioindiawest: '+5:30'
  koreacentral: '+9:00'
  koreasouth: '+9:00'
  northcentralus: '-6:00'
  northeurope: '0:00'
  norwayeast: '+1:00'
  norwaywest: '+1:00'
  southafricanorth: '+2:00'
  southafricawest: '+2:00'
  southcentralus: '-6:00'
  southindia: '+5:30'
  southeastasia: '+8:00'
  swedencentral: '+1:00'
  switzerlandnorth: '+1:00'
  switzerlandwest: '+1:00'
  uaecentral: '+3:00'
  uaenorth: '+3:00'
  uksouth: '0:00'
  ukwest: '0:00'
  usdodcentral: '-6:00'
  usdodeast: '-5:00'
  usgovarizona: '-7:00'
  usgoviowa: '-6:00'
  usgovtexas: '-6:00'
  usgovvirginia: '-5:00'
  westcentralus: '-7:00'
  westeurope: '+1:00'
  westindia: '+5:30'
  westus: '-8:00'
  westus2: '-8:00'
  westus3: '-7:00'
}
var TimeZones = {
  australiacentral: 'AUS Eastern Standard Time'
  australiacentral2: 'AUS Eastern Standard Time'
  australiaeast: 'AUS Eastern Standard Time'
  australiasoutheast: 'AUS Eastern Standard Time'
  brazilsouth: 'E. South America Standard Time'
  brazilsoutheast: 'E. South America Standard Time'
  canadacentral: 'Eastern Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  chinaeast: 'China Standard Time'
  chinaeast2: 'China Standard Time'
  chinanorth: 'China Standard Time'
  chinanorth2: 'China Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'Central Europe Standard Time'
  francesouth: 'Central Europe Standard Time'
  germanynorth: 'Central Europe Standard Time'
  germanywestcentral: 'Central Europe Standard Time'
  japaneast: 'Tokyo Standard Time'
  japanwest: 'Tokyo Standard Time'
  jioindiacentral: 'India Standard Time'
  jioindiawest: 'India Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'GMT Standard Time'
  norwayeast: 'Central Europe Standard Time'
  norwaywest: 'Central Europe Standard Time'
  southafricanorth: 'South Africa Standard Time'
  southafricawest: 'South Africa Standard Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  swedencentral: 'Central Europe Standard Time'
  switzerlandnorth: 'Central Europe Standard Time'
  switzerlandwest: 'Central Europe Standard Time'
  uaecentral: 'Arabian Standard Time'
  uaenorth: 'Arabian Standard Time'
  uksouth: 'GMT Standard Time'
  ukwest: 'GMT Standard Time'
  usdodcentral: 'Central Standard Time'
  usdodeast: 'Eastern Standard Time'
  usgovarizona: 'Mountain Standard Time'
  usgoviowa: 'Central Standard Time'
  usgovtexas: 'Central Standard Time'
  usgovvirginia: 'Eastern Standard Time'
  westcentralus: 'Mountain Standard Time'
  westeurope: 'Central Europe Standard Time'
  westindia: 'India Standard Time'
  westus: 'Pacific Standard Time'
  westus2: 'Pacific Standard Time'
  westus3: 'Mountain Standard Time'
}


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

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  parent: automationAccount
  name: RunbookName
  location: Location
  tags: Tags
  properties: {
    runbookType: 'PowerShell'
    logProgress: false
    logVerbose: false
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/scale.ps1'
      version: '1.0.0.0'
    }
  }
}

resource schedules 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = [for i in range(0, 4): {
  parent: automationAccount
  name: '${HostPoolName}_${(i+1)*15}min'
  properties: {
    advancedSchedule: {}
    description: null
    expiryTime: null
    frequency: 'Hour'
    interval: 1
    startTime: dateTimeAdd(Timestamp, 'PT${(i+1)*15}M')
    timeZone: TimeZones[Location]
  }
}]

resource jobSchedules 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for i in range(0, 4): {
  parent: automationAccount
  #disable-next-line use-stable-resource-identifiers
  name: guid(Timestamp, RunbookName, HostPoolName, string(i))
  properties: {
    parameters: {
      TenantId: subscription().tenantId
      SubscriptionId: subscription().subscriptionId
      EnvironmentName: environment().name
      ResourceGroupName: HostPoolResourceGroupName
      HostPoolName: HostPoolName
      MaintenanceTagName: 'Maintenance'
      TimeDifference: TimeDifferences[Location]
      BeginPeakTime: BeginPeakTime
      EndPeakTime: EndPeakTime
      SessionThresholdPerCPU: SessionThresholdPerCPU
      MinimumNumberOfRDSH: MinimumNumberOfRdsh
      LimitSecondsToForceLogOffUser: LimitSecondsToForceLogOffUser
      LogOffMessageTitle: 'Machine is about to shutdown.'
      LogOffMessageBody: 'Your session will be logged off. Please save and close everything.'
    }
    runbook: {
      name: runbook.name
    }
    runOn: null
    schedule: {
      name: schedules[i].name
    }
  }
}]

resource diagnostics 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if (!empty(LogAnalyticsWorkspaceResourceId)) {
  scope: automationAccount
  name: 'diag-${automationAccount.name}'
  properties: {
    logs: [
      {
        category: 'JobLogs'
        enabled: true
      }
      {
        category: 'JobStreams'
        enabled: true
      }
    ]
    workspaceId: LogAnalyticsWorkspaceResourceId
  }
}

// Gives the Automation Account the "Desktop Virtualization Power On Off Contributor" role on the resource groups containing the hosts and host pool
module roleAssignments'modules/roleAssignments.bicep' = [for i in range(0, length(RoleAssignments)): {
  name: 'RoleAssignment_${RoleAssignments[i]}'
  scope: resourceGroup(RoleAssignments[i])
  params: {
    PrincipalId: automationAccount.identity.principalId
    RoleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '40c5ff49-9181-41f8-ae61-143b0e78555e') // Desktop Virtualization Power On Off Contributor
  }
}]
