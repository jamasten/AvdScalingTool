param PrincipalId string
param RoleDefinitionId string


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(PrincipalId, RoleDefinitionId, resourceGroup().id) // who what where
  properties: {
    roleDefinitionId: RoleDefinitionId
    principalId: PrincipalId
    principalType: 'ServicePrincipal'
  }
}
