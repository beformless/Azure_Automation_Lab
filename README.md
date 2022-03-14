## Azure_Automation_Lab
 
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
Step by step directions = Home > Automation Accounts > azautomation > Configuration Management > State Configuration (DSC) > + Add > simple-vm > Connect > Check Reboot Node if Needed > Ok

# Enable Desired State Configuration for a virtual machine - PowerShell
Register-AzAutomationDscNode -AutomationAccountName azautomation -AzureVMName simple-vm -ResourceGroupName windows-vms-rg -NodeConfigurationName "DSCConfiguration.DomainController"

# Delete a resource to clean up your work
Remove-AzResourceGroup -Name ExampleResourceGroup