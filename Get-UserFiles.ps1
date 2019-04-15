#__________________BEGIN SCRIPT__________________________
#########################

New-Item -Path "c:\" -Name "Usersettings" -ItemType "directory"
# Write Information to the screen
Write-Host -ForegroundColor yellow "Exporting the list of users to c:\usersettings\users.csv"
# List the users in c:\users and export to the local profile for calling later
dir C:\Users | select Name | Export-Csv -Path C:\usersettings\users.csv -NoTypeInformation
$Users = Import-Csv C:\usersettings\users.csv
#
Foreach ($User in $Users) 
{   $Username = $User.name
    # New-Item -Path c:\Usersettings\$Username -ItemType "directory"
    # New-Item -Path c:\Usersettings\$Username\Outlook -ItemType "directory"
    Copy-Item -path C:\Users\$Username\AppData\Local\Microsoft\Outlook\RoamCache -Destination C:\Usersettings\$Username\Outlook -Recurse -Force  -EA SilentlyContinue -Verbose
    Copy-Item -path "C:\Users\$Username\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" -Destination C:\Usersettings\$Username\Chrome\Bookmarks -Recurse -Force  -EA SilentlyContinue -Verbose
    Copy-Item -path C:\Users\$Username\Favorites -Destination C:\Usersettings\$Username\Favorites -Recurse -Force  -EA SilentlyContinue -Verbose

} 


