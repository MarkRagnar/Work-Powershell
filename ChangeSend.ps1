Param (
[Parameter(Mandatory=$true)]
[string]$Username,
[Parameter(Mandatory=$true)]
[string]$Mailbox = "ap-bp"
)
Remove-ADPermission -Identity $Mailbox -User $Username -Extendedrights "Send As"
Set-Mailbox $Mailbox -GrantSendOnBehalfTo $Username