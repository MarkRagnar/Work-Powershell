#This is where we define the parameters.
#It prompts for username and the forward to email address. 
#Be sure to edit the variables to match your environment. 
Param (
[Parameter(Mandatory=$true)]
[string]$Username,
[Parameter(Mandatory=$true)]
[string]$Delegate,
[string]$DisabledUsersOU="OU=Disabled,OU=Users,   O=com",
[string]$ArchiveDB="Archive1",
[string]$ExchangeURI="http://Server/PowerShell/",
[string]$ExportPath="\\Server\PSTArchives\Former Employees"
)

#Here we create the connection to the exchange server.
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeURI  -Authentication Kerberos
Import-PSSession $ExchangeSession
#
#Here we import the tools to work with AD and Exchange
#
Import-Module ActiveDirectory
#
#This is where group memberships are removed.
#
Get-ADPrincipalGroupMembership -Identity $Username | ForEach-Object {Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $_ -Confirm:$False}
#
#
#This is where we disable the account
#
Disable-ADAccount -Identity $Username
#
#This is where we specify where the user will be moved in AD.
#
Get-ADUser $Username | Move-ADObject -TargetPath $DisabledUsersOU
#
#This is where we remove Activesync Devices
#
$MobileDevices = Get-ActiveSyncDeviceStatistics -mailbox $Username
$MobileDevices | ForEach-Object {$Guid = $_.guid.ToString(); Remove-ActiveSyncDevice -id $Guid -Confirm:$False}
#
#This is where we convert the mailbox to shared, set delegate permissions  and hide the account in Exchange. 
Set-Mailbox -Identity $Username -Type Shared -HiddenFromAddressListsEnabled $true -GrantSendOnBehalfTo $Delegate
Add-MailboxPermission $Username -User $Delegate -AccessRights FullAccess
#
#This is where we move the mailbox to the archive database
# New-MoveRequest -Identity $Username -TargetDatabase $ArchiveDB
#OR (unremark to activate one or the other)
#This is where we export to PST
New-MailboxExportRequest -Mailbox $Username -FilePath $ExportPath\$Username.pst -BadItemLimit 50 -confirm:$false
#IF exporting  to .pst, remove mailbox when archive finished.
do {sleep 60}
while ((Get-MailboxExportRequest | `
	Where-Object{$_.FilePath -like "*$Username.pst"}).Status -ne "Completed")
Disable-Mailbox $Username -Confirm:$false
