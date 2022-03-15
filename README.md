## Azure_Automation_Lab

.AUTHOR Jeremy Scarbro

# Create Resource group for Automation account - Azure CLI
az group create --name automation-account-rg --location westus

# Create Automation account - Azure CLI
az automation account create --automation-account-name azautomationaccount --location westus --resource-group automation-account-rg

# Enable Managed Identities - Azure Portal
Step by step directions =  Home > Automation Accounts > azautomationaccount > Account settings > Identity > System Assigned = On > Save > Yes

# Create Resource group - Azure CLI
az group create --name windows-vm-rg --location westus

# Deploy an Azure ARM Template - Windows VM - Azure CLI 
az deployment group create --resource-group windows-vm-rg --template-uri https://raw.githubusercontent.com/beformless/Azure_Automation_Lab/main/AzureWindowsServerVMDeploy.JSON

# Enable Desired State Configuration for a virtual machine - Azure Portal
Step by step directions = Home > Automation Accounts > azautomation > Configuration Management > State Configuration (DSC) > + Add > mydscdc > Connect > Check Reboot Node if Needed > Ok

# Import modules
Home > Automation Accounts >azautomationaccount > Shared Resources > Modules > Import ActiveDirectoryDSC > Import xPSDesiredStateConfiguration

#Copy needed DSC Resource Modules to the VM

# Create a Credential 
Home > Automation Accounts > azautomationaccount > Shared Resources > Credentials > Add a Credential > Add the Credential specified within AzureADDCBuild.ps1

# Upload a configuration to Azure Automation - PowerShell
Import-AzAutomationDscConfiguration -SourcePath './AzureADDCBuild.ps1' -ResourceGroupName 'automation-account-rg' -AutomationAccountName 'azautomationaccount' -Published

# Complile a configuration into a node - PowerShell
Start-AzAutomationDscCompilationJob -ConfigurationName 'AzureADDCBuild' -ResourceGroupName 'automation-account-rg' -AutomationAccountName 'azautomationaccount'

# Get the ID of the DSC node and set a variable
$node = Get-AzAutomationDscNode -ResourceGroupName 'automation-account-rg' -AutomationAccountName 'azautomationaccount' -Name 'mydscdc'

# Assign the node configuration to the DSC node
Set-AzAutomationDscNode -ResourceGroupName 'automation-account-rg' -AutomationAccountName 'azautomationaccount' -NodeConfigurationName 'AzureADDCBuild' -NodeId $node.Id

# Start a DSC Deployment
Start-AzAutomationDscNodeConfigurationDeployment -NodeConfigurationName "AzureADDCBuild" -AutomationAccountName "azautomationaccount" -ResourceGroupName "automation-account-rg" -NodeName mydscdc -force
                        
# Delete a resource to clean up your work
Remove-AzResourceGroup -Name ExampleResourceGroup