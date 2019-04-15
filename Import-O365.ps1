#Connect to Office365 and create users from csv
#MRH 4/10/2018
$users = Import-Csv "S:\HCUsers.csv"
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential

$users | ForEach-Object { New-MsolUser -UserPrincipalName $_.UserPrincipalName -DisplayName $_.DisplayName -LastName $_.LastName -PreferredDataLocation $_.PreferredDataLocation }