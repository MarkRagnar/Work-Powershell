# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$LocalPwd = Get-Credential -Message "LocalPCpassword"
$DomainPwd = Get-Credential -Message "Domain Password"
$OU = "OU=Workstations,OU=Computers,DC=local"
$Workstations = Import-csv C:\Temp\PCS.csv
$Domain = "domain"

#Loop through each row containing user details in the CSV file 
foreach ($Workstation in $Workstations)
{

Add-Computer -ComputerName $Workstation.OldName -Domain $Domain -OUPath $OU -LocalCredential $LocalPwd -Credential $DomainPwd -NewName $Workstation.NewName -Restart

}
