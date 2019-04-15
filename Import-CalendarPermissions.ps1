$CalendarPerms = Import-Csv S:\path\calendarpermissions.csv
#Connect to O365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

Foreach ($Item in $CalendarPerms) 
{
Add-mailboxfolderpermission -identity ($Item.Mailbox +":\calendar") -user $Item.User -Accessrights $Item.Accessrights
}


#End, Exit O365