$OU=
Import-Module ActiveDirectory


Get-ADUser -SearchBase $OU -filter *  -properties displayname,samaccountname,Mail,lastLogonDate,enabled | select-object displayname,samaccountname,Mail,lastLogonDate,enabled | Export-Csv -Path c:\userinfo.csv
 
 
- Email Forwarding list 
Get-mailbox -OrganizationalUnit $OU | select Alias, DisplayName,ForwardingAddress | where {$_.ForwardingAddress -ne $Null} | Export-Csv c:\mailbox_forwarding.csv
 
- Which mailbox has “Full Access” to which mailbox
Get-Mailbox -OrganizationalUnit $OU | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | Export-Csv c:\mailboxpermissions.csv
 
- Shared calendar permissions
$AllSharedCalendars = ForEach($user in (Get-Mailbox  -OrganizationalUnit $OU )) { Get-MailboxFolderPermission -Identity "$($user.Alias):\calendar" | Select @{'Name'='Mailbox';'Expression'={$user.Alias}},User,@{l='AccessRights';e={$_.AccessRights}}}
$AllSharedCalendars | Export-Csv -Path c:\calendarpermissions.csv
 
- Distribution groups + members + email addresses
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
} | Export-CSV "C:\\Distribution-Group-Members.csv" -NoTypeInformation -Encoding UTF8
 
 
- security groups
Import-Module ActiveDirectory
$groups = Get-ADGroup -SearchBase $OU -Filter * 
foreach ($group in $groups)
    {
        Get-ADGroupMember $group -Recursive | select samaccountname | export-csv C:\glgz\$($group.name)_members.csv -notype
    }
 
•	Printer drivers and printer details
$printserver = "glgmapp01" 
Get-WMIObject -class Win32_Printer -computer $printserver | Select Name,DriverName,PortName | Export-CSV -path 'G:\printers\printers.csv'
 
 
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
 
List of legacy exchange mailboxes: (vbscript)
Option Explicit 
Dim objFSO, CNUsers, User  ' Objects 
Dim strFile, strPath, DisplayName, LegacyExchange ' Strings 
Set CNUsers = GetObject("LDAP://OU=User Structure,OU=Gall Legge Grant Munroe LLP(GLGM),OU=Customers,DC=bmchosting,DC=ca") 
set objFSO = createobject("Scripting.FileSystemObject")
strPath = "c:\temp\glgzExchangeAddress.txt" 
Set strFile = objFSO.CreateTextFile(strPath, True)
set objCSV = objFSO.createtextfile(FileName)
For Each User in CNUsers
     DisplayName = User.displayName
     LegacyExchange = User.LegacyExchangeDN
     strFile.writeline("Name:" & DisplayName & ",LegacyExchange:" & LegacyExchange)
Next
 
List of AD groups and group members

$groups = Get-ADGroup -SearchBase $OU -Filter *
foreach ($group in $groups)
    {
       write-host $group
        Get-ADGroupMember $group -Recursive | select samaccountname #| export-csv C:\glgz\$($group.name)_members.csv -notype
        
        write-host " --- "
    }

Get mailboxes that have archives:
Get-Mailbox | where {$_.ArchiveDatabase -ne $null} | 
