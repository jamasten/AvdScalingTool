param automationAccountName string
param beginPeakTime string = '8:00'
param endPeakTime string = '17:00'
param existingAutomationAccount bool
param hostPoolName string
param hostPoolResourceGroupName string
param limitSecondsToForceLogOffUser string = '0'
param location string = resourceGroup().location
param logAnalyticsWorkspaceResourceId string = ''
param minimumNumberOfRdsh string = '0'
@secure()
param scriptSasToken string = ''
param scriptUri string = 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/scale.ps1'
param sessionHostsResourceGroupName string
param sessionThresholdPerCPU string = '1'
param tags object
param timestamp string = utcNow('yyyyMMddhhmmss')
param time string = utcNow('u')

var locations = (loadJsonContent('data/locations.json'))[environment().name]
var roleAssignments = hostPoolResourceGroupName == sessionHostsResourceGroupName ? [
  hostPoolResourceGroupName
] : [
  hostPoolResourceGroupName
  sessionHostsResourceGroupName
]
var runbookName = 'AvdScalingTool'

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = if(!existingAutomationAccount) {
  name: automationAccountName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

resource automationAccount_existing 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccount.name
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  parent: automationAccount_existing
  name: runbookName
  location: location
  tags: tags
  properties: {
    runbookType: 'PowerShell'
    logProgress: false
    logVerbose: false
    publishContentLink: {
      uri: '${scriptUri}${first(scriptSasToken) == '?' ? scriptSasToken : '?${scriptSasToken}'}'
      version: '1.0.0.0'
    }
  }
}

resource schedules 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = [for i in range(0, 4): {
  parent: automationAccount_existing
  name: '${hostPoolName}_${(i+1)*15}min'
  properties: {
    advancedSchedule: {}
    description: null
    expiryTime: null
    frequency: 'Hour'
    interval: 1
    startTime: dateTimeAdd(time, 'PT${(i+1)*15}M')
    timeZone: locations[location].timeZone
  }
}]

resource jobSchedules 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for i in range(0, 4): {
  parent: automationAccount_existing
  #disable-next-line use-stable-resource-identifiers
  name: guid(time, runbookName, hostPoolName, string(i))
  properties: {
    parameters: {
      TenantId: subscription().tenantId
      SubscriptionId: subscription().subscriptionId
      EnvironmentName: environment().name
      ResourceGroupName: hostPoolResourceGroupName
      HostPoolName: hostPoolName
      MaintenanceTagName: 'Maintenance'
      TimeDifference: locations[location].timeDifference
      BeginPeakTime: beginPeakTime
      EndPeakTime: endPeakTime
      SessionThresholdPerCPU: sessionThresholdPerCPU
      MinimumNumberOfRDSH: minimumNumberOfRdsh
      LimitSecondsToForceLogOffUser: limitSecondsToForceLogOffUser
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

resource diagnostics 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  scope: automationAccount_existing
  name: 'diag-${automationAccountName}'
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
    workspaceId: logAnalyticsWorkspaceResourceId
  }
}

// Gives the Automation Account the "Desktop Virtualization Power On Off Contributor" role on the resource groups containing the hosts and host pool
module roleAssignments_ResourceGroups 'modules/roleAssignments.bicep' = [for i in range(0, length(roleAssignments)): {
  name: 'RoleAssignment_${roleAssignments[i]}_${timestamp}'
  scope: resourceGroup(roleAssignments[i])
  params: {
    PrincipalId: automationAccount_existing.identity.principalId
    RoleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '40c5ff49-9181-41f8-ae61-143b0e78555e') // Desktop Virtualization Power On Off Contributor
  }
}]
