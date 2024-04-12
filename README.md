# Azure Virtual Desktop Scaling Tool

This solution fully deploys the AVD Scaling Tool provided in the [Microsoft Learn documentation](https://docs.microsoft.com/azure/virtual-desktop/set-up-scaling-script) but in a Zero Trust configuration. While AVD AutoScale (aka Scaling Plans) has replaced this solution, AutoScale is not available in every Azure cloud yet. In the Microsoft Learn documentation, the AVD Scaling Tool solution makes use of an automation account and a logic app. To ease the burden of the administrator and reduce cost, we have opted for a function app instead.

The following resources are deployed with this solution:

* App Service Plan
* Application Insights
* Diagnostic Setting
* Function App
* Key Vault
* Private Endpoints
* Role Assignments
* Storage Account

By specifying a value for the "LogAnalyticsWorkspaceResourceId" parameter, the logs for the storage account and application insights data will be sent to the target Log Analytics Workspace.

## Prerequisites

Ensure the principal deploying this solution has Owner rights on the Azure resource group(s).

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
