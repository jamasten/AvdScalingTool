# Azure Virtual Desktop Scaling Tool

This solution fully deploys the AVD Scaling Tool provided in the [Microsoft Learn documentation](https://docs.microsoft.com/azure/virtual-desktop/set-up-scaling-script). While AVD AutoScale (aka Scaling Plans) has replaced this solution, AutoScale is not available in every Azure cloud yet. In the Microsoft Learn documentation, the AVD Scaling Tool solution makes use of a webhook and a logic app. To ease the burden of the administrator, we have opted for Automation schedules and job schedules instead. Webhooks expire over time and have to be managed. The following resources are deployed with this solution:

* Automation Account
  * Job Schedules
  * Runbook
  * Schedules
  * Diagnostic Setting (Optional)
* Role Assignments

By specifying a value for "LogAnalyticsWorkspaceResourceId" parameter, the Runbook job logs and stream will be sent to a Log Analytics Workspace.  Review this Docs page, "[View Automation logs in Azure Monitor logs](https://docs.microsoft.com/azure/automation/automation-manage-send-joblogs-log-analytics#view-automation-logs-in-azure-monitor-logs)", for the KQL queries to view the log data and create alerts.

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
    -AutomationAccountName '<Automation Account Name>' `
    -BeginPeakTime '<Start of Peak Usage>' `
    -EndPeakTime '<End of Peak Usage>' `
    -ExistingAutomationAccount '<$true or $false>' `
    -HostPoolName '<Host Pool Name>' `
    -HostPoolResourceGroupName '<Host Pool Resource Group Name>' `
    -LimitSecondsToForceLogOffUser '<Number of seconds>' `
    -LogAnalyticsWorkspaceResourceId '<Log Analytics Workspace Resource ID>' ` 
    -MinimumNumberOfRdsh '<Number of Session Hosts>' `
    -SessionHostsResourceGroupName '<Session Hosts Resource Group Name>' `
    -SessionThresholdPerCPU '<Number of sessions>' `
    -Tags '<Key / Value pairs of metadata for your resources>' `
    -TimeDifference '<Time zone offset>' `
    -Verbose
````

### Azure CLI

````cli
az deployment group create \
    --resource-group '<Resource Group Name>' \
    --template-uri 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/solution.json' \
    --parameters \
        AutomationAccountName='<Automation Account Name>' \
        BeginPeakTime='<Start of Peak Usage>' \
        EndPeakTime='<End of Peak Usage>' \
        ExistingAutomationAccount=' true or false' \
        HostPoolName='<Host Pool Name>' \
        HostPoolResourceGroupName='<Host Pool Resource Group Name>' \
        LimitSecondsToForceLogOffUser='<Number of seconds>' \
        LogAnalyticsWorkspaceResourceId='<Log Analytics Workspace Resource ID>' \
        MinimumNumberOfRdsh='<Number of Session Hosts>' \
        RecurrenceInterval='<Number of minutes for Logic App recurrence>' \
        SessionHostsResourceGroupName='<Session Hosts Resource Group Name>' \
        SessionThresholdPerCPU='<Number of sessions>' \
        TimeDifference='<Time zone offset>' \
````
