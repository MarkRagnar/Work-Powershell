#MRH 23 August 2018
#Add secondary email address to AD account

# Site Variables
$EmailDomain = "@domain.com"

#Input Variables
$UserName = Read-Host -Prompt "User Name:"
$Alias = Read-Host -Prompt "New email alias:"

#Derived Variables
$email = $Alias + $EmailDomain

#Action
# Import active directory module for running AD cmdlets
Import-Module activedirectory

Set-ADUser $Username -Add @{ProxyAddresses="smtp:$($email)"}
Write-Host "Alias $email added to $username$emaildomain"