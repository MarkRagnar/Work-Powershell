#Create Groups and populate given .csv files with members
Import-Module activedirectory
$Path = "c:\scripts\Groups"
$OU = "OU=Groups,OU=StevensVirgin,DC=local,DC=stevensvirgin,DC=com"
$Files = Get-ChildItem $Path\*.csv
foreach ($file in $files)
{
    $Groupname = $file.BaseName 
    New-ADGroup -Name $Groupname -Path $OU  -GroupCategory Distribution -GroupScope Universal 
    Write-Host $Groupname
    $Members = Import-Csv $file
    ForEach ($Member in $Members)
    {
     Add-ADGroupMember -Identity $Groupname -Member $Member.samaccountname
    }
}