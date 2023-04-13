# Azure Virtual Desktop Scaling Tool

This solution is a modernized version of the Scaling Tool provided in the [AVD documentation](https://docs.microsoft.com/azure/virtual-desktop/set-up-scaling-script) and is contained in one deployment. The Automation Account uses a System Assigned Identity with Contributor rights on the AVD resource groups, reducing the scope of given permissions. The following resources are deployed with this solution:

* Automation Account
  * Runbook
  * Webhook
  * Variable
  * Diagnostic Settings (Optional)
* Logic App
* Role Assignments

By specifying a value for "LogAnalyticsWorkspaceResourceId" parameter, the Runbook job logs and stream will be sent to a Log Analytics Workspace.  Review this Docs page, "[View Automation logs in Azure Monitor logs](https://docs.microsoft.com/azure/automation/automation-manage-send-joblogs-log-analytics#view-automation-logs-in-azure-monitor-logs)", for the KQL queries to view the log data and create alerts.

## Prerequisites

Ensure the principal deploying this solution has Owner rights on the Azure subscription.

## Deploy to Azure

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2Fsolution.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAvdScalingTool%2Fmain%2Fsolution.json)

### PowerShell

````powershell
New-AzResourceGroupDeployment `
    -ResourceGroupName '<Resource Group Name>' `
    -TemplateFile 'https://raw.githubusercontent.com/jamasten/AvdScalingTool/main/solution.json' `
    -AutomationAccountName '<Automation Account Name>' `
    -BeginPeakTime '<Start of Peak Usage>' `
    -EndPeakTime '<End of Peak Usage>' `
    -HostPoolName '<Host Pool Name>' `
    -HostPoolResourceGroupName '<Host Pool Resource Group Name>' `
    -HostsResourceGroupName '<Hosts Resource Group Name>' `
    -LimitSecondsToForceLogOffUser '<Number of seconds>' `
    -LogAnalyticsWorkspaceResourceId '<Log Analytics Workspace Resource ID>' ` 
    -LogicAppName '<Name for the new or existing Logic App>' `
    -MinimumNumberOfRdsh '<Number of Session Hosts>' `
    -SessionThresholdPerCPU '<Number of sessions>' `
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
        HostPoolName='<Host Pool Name>' \
        HostPoolResourceGroupName='<Host Pool Resource Group Name>' \
        HostsResourceGroupName='<Hosts Resource Group Name>' \
        LimitSecondsToForceLogOffUser='<Number of seconds>' \
        LogAnalyticsWorkspaceResourceId='<Log Analytics Workspace Resource ID>' \
        LogicAppName='<Name for the new or existing Logic App>' \
        MinimumNumberOfRdsh='<Number of Session Hosts>' \
        RecurrenceInterval='<Number of minutes for Logic App recurrence>' \
        SessionThresholdPerCPU='<Number of sessions>' \
        TimeDifference='<Time zone offset>' \
````
