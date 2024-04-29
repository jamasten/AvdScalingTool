@description('The resource ID of the private DNS zone for Azure Blobs.')
param azureBlobsPrivateDnsZoneResourceId string

@description('The resource ID of the private DNS zone for Azure Files.')
param azureFilesPrivateDnsZoneResourceId string

@description('The resource ID of the private DNS zone for Azure Functions.')
param azureFunctionsPrivateDnsZoneResourceId string

@description('The resource ID of the private DNS zone for Azure Queues.')
param azureQueuesPrivateDnsZoneResourceId string

@description('The resource ID of the private DNS zone for Azure Tables.')
param azureTablesPrivateDnsZoneResourceId string

@allowed([
  '00:00'
  '01:00'
  '02:00'
  '03:00'
  '04:00'
  '05:00'
  '06:00'
  '07:00'
  '08:00'
  '09:00'
  '10:00'
  '11:00'
  '12:00'
  '13:00'
  '14:00'
  '15:00'
  '16:00'
  '17:00'
  '18:00'
  '19:00'
  '20:00'
  '21:00'
  '22:00'
  '23:00'
])
@description('The time of day when the peak period begins.')
param beginPeakTime string = '08:00'

@description('The resource ID of the target subnet delegated for outbound access for the function app.')
param delegatedSubnetResourceId string

@allowed([
  '00:00'
  '01:00'
  '02:00'
  '03:00'
  '04:00'
  '05:00'
  '06:00'
  '07:00'
  '08:00'
  '09:00'
  '10:00'
  '11:00'
  '12:00'
  '13:00'
  '14:00'
  '15:00'
  '16:00'
  '17:00'
  '18:00'
  '19:00'
  '20:00'
  '21:00'
  '22:00'
  '23:00'
])
@description('The time of day when the peak period ends.')
param endPeakTime string = '17:00'

@allowed([
  'dev'
  'prod'
  'test'
])
@description('The abbreviation for the target environment.')
param environmentAbbreviation string

@description('The name of the AVD host pool.')
param hostPoolName string

@description('The name of the resource group containing the AVD host pool.')
param hostPoolResourceGroupName string

@maxLength(3)
@description('The unique identifier between each business unit or project supporting AVD in your tenant. This is the unique naming component between each AVD stamp.')
param identifier string

@description('The number days before the key expires. The key will be rotated before it expires and is used to encrypt the storage account.')
param keyExpirationInDays int = 30

@description('The resource ID of the private DNS zone for the key vault.')
param keyVaultPrivateDnsZoneResourceId string

@description('The number of seconds to wait before forcing a user to log off. This setting should only be used if session time limits are not managed on host.')
param limitSecondsToForceLogOffUser string = '0'

@description('The target location for the deployed resources.')
param location string = resourceGroup().location

@description('The resource ID of the log analytics workspace for monitoring the resources in this solution.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The minimum number of session host VMs to keep running during off-peak hours. The scaling tool will not work if all virtual machines are turned off and the Start VM On Connect solution is not enabled.')
param minimumNumberOfRdsh string = '0'

@description('The resource ID of the subnet for the private endpoints.')
param privateEndpointsSubnetResourceId string

@description('The resource ID of the Azure Monitor Private Link Scope.')
param privateLinkScopeResourceId string = ''

@description('The name of the resource group containing the AVD session hosts.')
param sessionHostsResourceGroupName string

@description('The maximum number of sessions per CPU that will be used as a threshold to determine when new session host VMs need to be started during peak hours')
param sessionThresholdPerCPU string = '1'

@description('The key / value pairs of metadata for the Azure resource groups and resources.')
param tags object = {}

@description('DO NOT MODIFY THIS VALUE! The timestamp is needed to differentiate deployments for certain Azure resources and must be set using a parameter.')
param timestamp string = utcNow('yyyyMMddhhmmss')

var applicationInsightsName = replace(namingConvention, 'resourceType', resourceTypes.applicationInsights)
var appServicePlanName = replace(namingConvention, 'resourceType', resourceTypes.appServicePlans)
var diagnosticsSettingName = replace(namingConvention, 'resourceType', '${resourceTypes.diagnosticSettings}-subType')
var fileShareName = 'function-app'
var functionAppName = replace(namingConvention, 'resourceType', resourceTypes.functionApps)
var functionName = replace(namingConvention, 'resourceType', resourceTypes.functions)
var keyVaultName = replace(replace(namingConvention, 'resourceType', resourceTypes.keyVaults), '-', '')
var locations = loadJsonContent('data/locations.json')[environment().name]
var namingConvention = '${identifier}-resourceType-scaling-avd-${environmentAbbreviation}-${locations[location].abbreviation}'
var networkInterfaceName = replace(namingConvention, 'resourceType', '${resourceTypes.networkInterfaces}-subType')
var privateEndpointName = replace(namingConvention, 'resourceType', '${resourceTypes.privateEndpoints}-subType')
var resourceTypes = loadJsonContent('data/resourceTypes.json')
var roleAssignments = hostPoolResourceGroupName == sessionHostsResourceGroupName
  ? [
      hostPoolResourceGroupName
    ]
  : [
      hostPoolResourceGroupName
      sessionHostsResourceGroupName
    ]
var storageAccountName = replace(replace(namingConvention, 'resourceType', resourceTypes.storageAccounts), '-', '')
var storagePrivateDnsZoneResourceIds = [
  azureBlobsPrivateDnsZoneResourceId
  azureFilesPrivateDnsZoneResourceId
  azureQueuesPrivateDnsZoneResourceId
  azureTablesPrivateDnsZoneResourceId
]
var storageSubResources = [
  'blob'
  'file'
  'queue'
  'table'
]
var userAssignedIdentityName = replace(namingConvention, 'resourceType', resourceTypes.userAssignedIdentities)

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: contains(tags, 'Microsoft.ManagedIdentity/userAssignedIdentities')
    ? tags['Microsoft.ManagedIdentity/userAssignedIdentities']
    : {}
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentity.name, 'e147488a-f6f5-4113-8e2d-b22465e65bf6', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: contains(tags, 'Microsoft.KeyVault/vaults') ? tags['Microsoft.KeyVault/vaults'] : {}
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: environmentAbbreviation == 'dev' || environmentAbbreviation == 'test' ? 7 : 90
    tenantId: subscription().tenantId
  }
}

resource privateEndpoint_vault 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: replace(privateEndpointName, 'subType', 'kv')
  location: location
  tags: contains(tags, 'Microsoft.Network/privateEndpoints') ? tags['Microsoft.Network/privateEndpoints'] : {}
  properties: {
    customNetworkInterfaceName: replace(networkInterfaceName, 'subType', 'kv')
    privateLinkServiceConnections: [
      {
        name: replace(privateEndpointName, 'subType', 'kv')
        properties: {
          privateLinkServiceId: vault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointsSubnetResourceId
    }
  }
}

resource privateDnsZoneGroup_vault 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: privateEndpoint_vault
  name: keyVaultName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'ipconfig1'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZoneResourceId
        }
      }
    ]
  }
}

resource key_storageAccount 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: vault
  name: 'StorageEncryptionKey'
  properties: {
    attributes: {
      enabled: true
    }
    keySize: 4096
    kty: 'RSA'
    rotationPolicy: {
      attributes: {
        expiryTime: 'P${string(keyExpirationInDays)}D'
      }
      lifetimeActions: [
        {
          action: {
            type: 'Notify'
          }
          trigger: {
            timeBeforeExpiry: 'P10D'
          }
        }
        {
          action: {
            type: 'Rotate'
          }
          trigger: {
            timeAfterCreate: 'P${string(keyExpirationInDays - 7)}D'
          }
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: contains(tags, 'Microsoft.Storage/storageAccounts') ? tags['Microsoft.Storage/storageAccounts'] : {}
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'PrivateLink'
    allowSharedKeyAccess: true
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'None'
    }
    defaultToOAuthAuthentication: false
    dnsEndpointType: 'Standard'
    encryption: {
      identity: {
        userAssignedIdentity: userAssignedIdentity.id
      }
      requireInfrastructureEncryption: true
      keyvaultproperties: {
        keyvaulturi: vault.properties.vaultUri
        keyname: key_storageAccount.name
      }
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.KeyVault'
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {
        versions: 'SMB3.1.1;'
        authenticationMethods: 'NTLMv2;'
        channelEncryption: 'AES-128-GCM;AES-256-GCM;'
      }
    }
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileServices
  name: fileShareName
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
}

resource privateEndpoints_storage 'Microsoft.Network/privateEndpoints@2023-04-01' = [
  for resource in storageSubResources: {
    name: replace(privateEndpointName, 'subType', '${resource}-st')
    location: location
    tags: contains(tags, 'Microsoft.Network/privateEndpoints') ? tags['Microsoft.Network/privateEndpoints'] : {}
    properties: {
      customNetworkInterfaceName: replace(networkInterfaceName, 'subType', '${resource}-st')
      privateLinkServiceConnections: [
        {
          name: replace(privateEndpointName, 'subType', '${resource}-st')
          properties: {
            privateLinkServiceId: storageAccount.id
            groupIds: [
              resource
            ]
          }
        }
      ]
      subnet: {
        id: privateEndpointsSubnetResourceId
      }
    }
  }
]

resource privateDnsZoneGroups_storage 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = [
  for (resource, i) in storageSubResources: {
    parent: privateEndpoints_storage[i]
    name: storageAccount.name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'ipconfig1'
          properties: {
            #disable-next-line use-resource-id-functions
            privateDnsZoneId: storagePrivateDnsZoneResourceIds[i]
          }
        }
      ]
    }
  }
]

resource diagnosticSetting_storage_blob 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' =
  if (!empty(logAnalyticsWorkspaceResourceId)) {
    scope: blobService
    name: replace(diagnosticsSettingName, 'subType', 'blob-st')
    properties: {
      logs: [
        {
          category: 'StorageWrite'
          enabled: true
        }
      ]
      metrics: [
        {
          category: 'Transaction'
          enabled: true
        }
      ]
      workspaceId: logAnalyticsWorkspaceResourceId
    }
  }

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: contains(tags, 'Microsoft.Insights/components') ? tags['Microsoft.Insights/components'] : {}
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

module privateLinkScope 'modules/privateLinkScope.bicep' = {
  name: 'PrivateLinkScope_${timestamp}'
  scope: resourceGroup(split(privateLinkScopeResourceId, '/')[2], split(privateLinkScopeResourceId, '/')[4])
  params: {
    applicationInsightsName: applicationInsightsName
    applicationInsightsResourceId: applicationInsights.id
    privateLinkScopeResourceId: privateLinkScopeResourceId
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: contains(tags, 'Microsoft.Web/serverfarms') ? tags['Microsoft.Web/serverfarms'] : {}
  sku: {
    tier: 'ElasticPremium'
    name: 'EP1'
  }
  kind: 'functionapp'
  properties: {
    targetWorkerSizeId: 3
    targetWorkerCount: 1
    maximumElasticWorkerCount: 20
    zoneRedundant: false
  }
  dependsOn: [
    privateEndpoints_storage
    privateDnsZoneGroups_storage
  ]
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: contains(tags, 'Microsoft.Web/sites') ? tags['Microsoft.Web/sites'] : {}
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,'2019-06-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,'2019-06-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: fileShareName
        }
        {
          name: 'BeginPeakTime'
          value: beginPeakTime
        }
        {
          name: 'EndPeakTime'
          value: endPeakTime
        }
        {
          name: 'EnvironmentName'
          value: environment().name
        }
        {
          name: 'HostPoolName'
          value: hostPoolName
        }
        {
          name: 'HostPoolResourceGroupName'
          value: hostPoolResourceGroupName
        }
        {
          name: 'LimitSecondsToForceLogOffUser'
          value: limitSecondsToForceLogOffUser
        }
        {
          name: 'LogOffMessageBody'
          value: 'This session is about to be logged off. Please save your work.'
        }
        {
          name: 'LogOffMessageTitle'
          value: 'Session Log Off'
        }
        {
          name: 'MaintenanceTagName'
          value: 'Maintenance'
        }
        {
          name: 'MinimumNumberOfRDSH'
          value: minimumNumberOfRdsh
        }
        {
          name: 'ResourceManagerUrl'
          value: environment().resourceManager
        }
        {
          name: 'SessionThresholdPerCPU'
          value: sessionThresholdPerCPU
        }
        {
          name: 'SubscriptionId'
          value: subscription().subscriptionId
        }
        {
          name: 'TenantId'
          value: subscription().tenantId
        }
        {
          name: 'TimeDifference'
          value: locations[location].timeDifference
        }
      ]
      cors: {
        allowedOrigins: [
          environment().portal
        ]
      }
      ftpsState: 'FtpsOnly'
      netFrameworkVersion: 'v6.0'
      powerShellVersion: '7.2'
      use32BitWorkerProcess: false
    }
    virtualNetworkSubnetId: delegatedSubnetResourceId
    vnetContentShareEnabled: true
    vnetRouteAllEnabled: true
  }
}

resource privateEndpoint_functionApp 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: replace(privateEndpointName, 'subType', 'fa')
  location: location
  properties: {
    customNetworkInterfaceName: replace(networkInterfaceName, 'subType', 'fa')
    privateLinkServiceConnections: [
      {
        name: replace(privateEndpointName, 'subType', 'fa')
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointsSubnetResourceId
    }
  }
}

resource privateDnsZoneGroup_functionApp 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: privateEndpoint_functionApp
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'ipconfig1'
        properties: {
          privateDnsZoneId: azureFunctionsPrivateDnsZoneResourceId
        }
      }
    ]
  }
}

resource function 'Microsoft.Web/sites/functions@2020-12-01' = {
  parent: functionApp
  name: functionName
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'Timer'
          type: 'timerTrigger'
          direction: 'in'
          schedule: '0 */15 * * * *'
        }
      ]
    }
    files: {
      'requirements.psd1': loadTextContent('artifacts/requirements.psd1')
      'run.ps1': loadTextContent('artifacts/run.ps1')
      '../profile.ps1': loadTextContent('artifacts/profile.ps1')
    }
  }
  dependsOn: [
    privateEndpoint_functionApp
    privateDnsZoneGroup_functionApp
  ]
}

// Gives the function app the "Desktop Virtualization Power On Off Contributor" role on the resource groups containing the hosts and host pool
module roleAssignments_ResourceGroups 'modules/roleAssignments.bicep' = [
  for i in range(0, length(roleAssignments)): {
    name: 'RoleAssignment_${roleAssignments[i]}_${timestamp}'
    scope: resourceGroup(roleAssignments[i])
    params: {
      PrincipalId: functionApp.identity.principalId
      RoleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '40c5ff49-9181-41f8-ae61-143b0e78555e') // Desktop Virtualization Power On Off Contributor
    }
  }
]
