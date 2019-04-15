
$ServerName = "RDG01"
$Domain = ".local" 
$ExternalDomain = "domain.com"
$ExternalName = "remote"
$OU = "IT"
$Company = ""
$City = "Vancouver"
$State = "British Columbia"
$CountryCode = "CA"
$RemoteUserGroup = "RDGUsers"



$

# Import active directory module for running AD cmdlets and RD Module
Import-Module activedirectory
Import-Module RemoteDesktop
  

#Rename and join domain
Add-Computer -Domain $Domain  -NewName $Servername


#Add RDG
Add-WindowsFeature -Name Web-Server, Web-Mgmt-Tools,RDS-Gateway -IncludeAllSubFeature 

#Create Policies
New-Item -Path RDS:\GatewayServer\CAP -Name DefaultCAP -UserGroups $RemoteUserGroup@$Domain -Authmethod 1
New-Item -Path RDS:\GatewayServer\RAP -Name Default RAP -UserGroups $RemoteUserGroup@$Domain -ComputerGroupType 1 -ComputerGroup 'Domain Computers'@$Domain






#