
Import-Module ActiveDirectory
$OU = "OU=Workstations,OU=Computers,DC=com,DC=local"
$Computers =  Get-ADComputer -Filter * -SearchBase "$OU" | Select Name
$LogPath = "c:\utils"

$Log = @()
ForEach ($Computer in (Get-Content $Computers))
{   ForEach ($Drive in "C","D")
    {   If (Test-Path "\\$Computer\$($Drive)`$\")
        {   $Log += ForEach ($PST in ($PSTS = Get-ChildItem "\\$Computer\$($Drive)`$\" -Include *.pst -Recurse -Force -erroraction silentlycontinue))
            {   New-Object PSObject -Property @{
                    ComputerName = $Computer
                    Path = $PST.DirectoryName
                    FileName = $PST.BaseName
                    Size = "{0:N2} MB" -f ($PST.Length / 1mb)
                }
            }
        }
    }
}

$Log | Export-Csv $LogPath\PSTLog.csv -NoTypeInformation