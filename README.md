# Azure Virtual Desktop Scaling Tool

This solution deploys an adaptation of the AVD Scaling Tool provided in the [Microsoft Learn documentation](https://docs.microsoft.com/azure/virtual-desktop/set-up-scaling-script). While AVD AutoScale (aka Scaling Plans) has replaced the AVD Scaling Tool, AutoScale is not available in every Azure cloud yet. In the Microsoft Learn documentation, the AVD Scaling Tool solution makes use of an automation account and a logic app. To ease the burden of the administrator and reduce cost, we have opted for a function app instead. Lastly, to improve security, this solution has been developed to use a zero trust configuration.

The following resources are deployed with this solution:

* App Service Plan
* Application Insights
* Diagnostic Setting
* Function App
* Key Vault
* Private Endpoints
* Role Assignments
* Storage Account

## Prerequisites

* **Privileges** - Ensure the principal deploying this solution has Owner and Key Vault Administrator rights on the subscription.
* **Monitoring** - By specifying a value for the "LogAnalyticsWorkspaceResourceId" parameter, the logs for the storage account and application insights data will be sent to the target Log Analytics Workspace. Since this solution uses a zero trust configuration, an Azure Monitor Private Link Scope is required.
* **Networking**
  * The following private DNS zones must exist:
    * Azure Blobs
    * Azure Files
    * Azure Functions
    * Azure Queues
    * Azure Tables
    * Key Vault
  * Delegated Subnet: this solution deploys a Function App with private outbound access. This configuration requires a delegated subnet for "Microsoft.Web/serverFarms". [Reference](https://learn.microsoft.com/azure/app-service/configure-vnet-integration-enable#configure-with-azure-powershell)

## Deploy to Azure

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2FuiDefinition.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2FuiDefinition.json)

### PowerShell

````powershell
New-AzResourceGroupDeployment `
    -ResourceGroupName '<Resource Group Name>' `
    -TemplateFile 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/solution.json' `
    -Verbose
````

### Azure CLI

````cli
az deployment group create \
    --resource-group '<Resource Group Name>' \
    --template-uri 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/solution.json' \
````
