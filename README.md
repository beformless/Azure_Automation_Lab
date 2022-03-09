# Azure_Automation_Lab
 
# Create Resource group for Automation account - Azure CLI
az group create --name automation-rg --location westus

# Create Automation account - Azure CLI
az automation account create --automation-account-name azautomation --location westus --resource-group automation-rg

# Enabe Managed Identities - Azure Portal
## Home > Automation Accounts > azautomation > Account settings > Identity > System Assigned = On

# Create Resource group - Azure CLI
az group create --name windows-vms-rg --location westus

# Deploy an Azure ARM Template - Windows VM - Azure CLI 
az deployment group create --resource-group windows-vms-rg --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/vm-simple-windows/azuredeploy.json

# Enable Desired State Configuration for a virtual machine - Azure Portal
## Home > Automation Accounts > azautomation > Configuration Management > State Configuration (DSC) > + Add > simple-vm > Connect > Check Reboot Node if Needed > Ok

# https://docs.microsoft.com/en-us/powershell/module/az.automation/register-azautomationdscnode?view=azps-7.3.0
Register-AzAutomationDscNode -AutomationAccountName azautomation -AzureVMName simple-vm -ResourceGroupName windows-vms-rg -NodeConfigurationName "ContosoConfiguration.webserver"