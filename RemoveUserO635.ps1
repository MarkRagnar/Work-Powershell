#This is where we define the parameters and variables for the site environment.
#It prompts for username and the delegate for the shared mailbox. 
#Be sure to edit the variables to match your environment. 
Param (
[Parameter(Mandatory=$true,Position=1)]
[string]$Username,
[Parameter(Mandatory=$true,Position=2)]
[string]$Delegate
)
$DisabledUsersOU="OU=Departed,OU=Users,OU=Company,DC=local,DC=Company,DC=com"
$EmailDomain="@company.com"
$O365Admin="admin@company.onmicrosoft.com"
$O365User = $Username + $EmailDomain
$O365Delegate = $Delegate + $EmailDomain
$ExternalAutoReply = "This is an automated reply. $O365User is no longer with the company For your convenience, this message has been forwarded"
$InternalAutoReply = $ExternalAutoReply 


#Here we import the tools to work with AD 
#
Import-Module ActiveDirectory
Import-Module ADSync
#
#Here we create the connection to Exchange Online
$UserCredential = Get-Credential -Message "Enter Credentials for $O365Admin " -UserName $O365Admin
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
#
#Here we create the connection to Azure AD
# Connect-MsolService -Credential $UserCredential
#This is where group memberships are removed.
#
Get-ADPrincipalGroupMembership -Identity $Username | ForEach-Object {Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $_ -Confirm:$False}
#
#
#This is where we disable the account
#
Disable-ADAccount -Identity $Username
#
#This is where we move the user will be in AD.
#
Get-ADUser $Username | Move-ADObject -TargetPath $DisabledUsersOU
#
#This where we hide the address in Exchange - this has to be done in AD, not O365
#This can't be done where the AS Schema has not been extended for Exchange
#
# Set-ADUser $Username -Replace @{msExchHideFromAddressLists=$true}
#
#This is where we remove Activesync Devices
#
$MobileDevices = Get-MobileDeviceStatistics -mailbox $O365User
$MobileDevices | ForEach-Object {$Guid = $_.guid.ToString(); Get-MobileDeviceStatistics -id $Guid -Confirm:$False}
#
#This is where we convert the mailbox to shared, set delegate permissions   
Set-Mailbox -Identity $O365User -Type Shared  -GrantSendOnBehalfTo $O365Delegate
Add-MailboxPermission $O365User -User $O365Delegate -AccessRights FullAccess
Set-MailboxAutoReplyConfiguration -Identity $O365User -AutoReplyState Enabled -InternalMessage $InternalAutoReply -ExternalMessage $ExternalAutoReply
#
#This is where we remove all licenses from the user
#(get-MsolUser -UserPrincipalName $O365User).licenses.AccountSkuId |
#ForEach-Object {
#    Set-MsolUserLicense -UserPrincipalName $O365User -RemoveLicenses $_
#}
#Syncing with Azure will remove the licenses since the user has been moved to a non-synced OU
Start-ADSyncSyncCycle -PolicyType Delta
#This is where we close the connection to Office 365
Remove-PSSession $Session
#This is where we get really tired of this comment convention