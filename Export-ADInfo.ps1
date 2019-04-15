# Commands courtesy of A Keigher
# Made generic by MH
Import-Module ActiveDirectory

$OU = "OU=User Structure,DC=ca"
$printserver = "sserver" 
$PathRoot = Split-Path -parent "C:STVI\*.*"



List of all users (active or inactive)

Get-ADUser -SearchBase $OU -filter *  -properties displayname,samaccountname,Mail,lastLogonDate,enabled | select-object displayname,samaccountname,Mail,lastLogonDate,enabled |out-gridview

# Email Forwarding list 
Get-mailbox -OrganizationalUnit $OU | select Alias, DisplayName,ForwardingAddress | where {$_.ForwardingAddress -ne $Null} | Export-Csv c:\mailbox_forwarding.csv

# Which mailbox has �Full Access� to which mailbox
Get-Mailbox -OrganizationalUnit $OU | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | Export-Csv c:\mailboxpermissions.csv
#
#
 Shared calendar permissions
$AllSharedCalendars = ForEach($user in (Get-Mailbox  -OrganizationalUnit $OU )) { Get-MailboxFolderPermission -Identity "$($user.Alias):\calendar" | Select @{'Name'='Mailbox';'Expression'={$user.Alias}},User,@{l='AccessRights';e={$_.AccessRights}}}
$AllSharedCalendars | Export-Csv -Path c:\calendarpermissions.csv

# Distribution groups + members + email addresses
$Groups = Get-DistributionGroup -OrganizationalUnit $OU
$Groups | ForEach-Object {
$group = $_.Name
$members = ''
$emails = $emails=$_.primarysmtpaddress

Get-DistributionGroupMember $group | ForEach-Object {
        If($members) {
              $members=$members + ";" + $_.Name
           } Else {
              $members=$_.Name
           }
  }
New-Object -TypeName PSObject -Property @{
      GroupName = $group
Email = $emails
      Members = $members
     }
} | Export-CSV "C:\Distribution-Group-Members.csv" -NoTypeInformation -Encoding UTF8


 #	Printer drivers and printer details

Get-WMIObject -class Win32_Printer -computer $printserver | Select Name,DriverName,PortName | Export-CSV -path 'C:\printers\printers.csv'

List of exchange mailbox addresses:

get-mailbox -OrganizationalUnit $OU | foreach{ 
 write-output ("`n")
write-output("`nUser Name: " + $_.DisplayName+"`n")
for ($i=0;$i -lt $_.EmailAddresses.Count; $i++)
{$address = $_.EmailAddresses[$i] 
    write-output($address.AddressString.ToString()+"`t")
    if ($address.IsPrimaryAddress)
    { write-output("Primary Email Address`t") }
   else
   { write-output("Alias`t") }
}}

List of AD groups and group members

$groups = Get-ADGroup -SearchBase $OU -Filter *
foreach ($group in $groups)
    {
       write-host $group
        Get-ADGroupMember $group -Recursive | select samaccountname #| export-csv C:\STVI\$($group.name)_members.csv -notype
        
        write-host " --- "
    }

Get mailboxes that have archives:
Get-Mailbox | where {$_.ArchiveDatabase -ne $null} | Export-CSV -path 'C:\mailboxeswithArchives.csv'

