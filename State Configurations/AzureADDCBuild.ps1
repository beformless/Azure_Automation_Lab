#Written by Jeremy Scarbro - Security Engineer

#Begin PowerShell Script

Configuration AzureADDCBuild{
    
    #Download and Install Required Resources
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDSC'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    #Initialize Script Variables
    $DomainName = 'TheAbyss.net'

    #Designate Credentials, (Not Best practice) - Setup and Utilize Azure Key Vault
    $Credential = (get-credential)

    Node localhost{
        #------------------#
        # Base OS Settings #
        #------------------#

            #Set UAC Configuration
            UserAccountControl 'ChangeNotificationLevel'
            {
                IsSingleInstance  = 'Yes'
                NotificationLevel = 'AlwaysNotify' 
                SuppressRestart = $true       
            }

            #Set and monitor the Timezone
            TimeZone 'TimeZoneSet'
            {
                IsSingleInstance = 'Yes'
                TimeZone = 'Pacific Standard Time'
            }

            #Set and monitor PowerShell Execution policy
            PowerShellExecutionPolicy 'PowerShellExecutionPolicySet'
            {
                ExecutionPolicyScope = 'LocalMachine'
                ExecutionPolicy = 'RemoteSigned'
            }

        #------------------#
        # Install Services #
        #------------------#

            #Install Windows Feature AD-Domain-Services
            xWindowsFeature 'InstallAD'
            {
                Name = 'AD-Domain-Services'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
                DependsOn = '[xWindowsFeature]RSATADPowerShell'
            }

            #Install Windows Feature DNS 
            xWindowsFeature 'InstallDNS'
            {
                Name = 'DNS'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
                DependsOn = '[xWindowsFeature]InstallAD'
            }
            
            #Install Windows Feature RSAT AD PowerShell
            xWindowsFeature 'RSATADPowerShell'
            {
                Name = 'RSAT-AD-PowerShell'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
            }

            #Install Windows RSAT Active Directory Domain Services
            xWindowsFeature 'RSATADDS'
            {
                Name = 'RSAT-ADDS'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
                DependsOn = '[xWindowsFeature]InstallAD'
            }

            #Install Windows Feature RSAT DNS Server
            xWindowsFeature 'RSATDNSServer'
            {
                Name = 'RSAT-DNS-Server'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
                DependsOn = '[xWindowsFeature]InstallDNS'
            }

            #Configures the First Domain Controller in the Forest
            ADDomain 'ForestBuild'
            {
                DomainName = $DomainName
                Credential = $Credential
                SafemodeAdministratorPassword = $Credential
                DependsOn = '[xWindowsFeature]InstallDNS'
            }

        #------------------#
        # Monitor Services #
        #------------------#

            #Active Directory Service Monitoring (NTDS)
            Service 'NTDSService'
            {
                Name        = 'NTDS'
                StartupType = 'Automatic'
                State       = 'Running'
                DependsOn = '[ADDomain]ForestBuild'
            }

        #-----------------------#
        # Post-Install Services #
        #-----------------------#

            #Sets the Default Password and Lock-Out Policies
            ADDomainDefaultPasswordPolicy 'DomainPasswordPolicy'
            {
                DomainName = $DomainName
                PasswordHistoryCount = 24
                MinPasswordAge = 1440
                MaxPasswordAge = 525600
                MinPasswordLength = 17
                ComplexityEnabled = $true
                ReversibleEncryptionEnabled = $false
                LockoutDuration = 15
                LockoutObservationWindow = 15
                LockoutThreshold = 50
                DependsOn = '[ADDomain]ForestBuild'
            }

            #Renames the Default-First-Site-Name
            ADReplicationSite 'RenameFirstSite'
            {
                Name = 'TheAbyss-Primary-Site'
                RenameDefaultFirstSiteName = $true
                Ensure = 'Present'
                DependsOn = '[ADDomain]ForestBuild'
            }
            
            #Creates the KDS Root Key used to Build Group Managed Service Accounts
            ADKDSKey 'KDSRootKey'
            {
                Ensure = 'Present'
                EffectiveTime = '2/1/2022 09:00'
                AllowUnsafeEffectiveTime = $true
                DependsOn = '[ADDomain]ForestBuild'
            }   

    }
}