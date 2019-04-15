#DisableServices.ps1 Disables a list of services from a .csv file
#Set path and name of csv here
$FileName = '.\disabledservices.csv'
$ServiceList = import-csv $FileName
$ComputerName = Read-Host -Prompt "Enter Computer Name, or Blank for local"
try {
    If ($ComputerName -ne "") {
    $s = New-PSSession $ComputerName -ErrorAction Stop
    }
}
catch {
Write-Host "Unable to reach computer " $ComputerName
Break
}

ForEach ($ServiceList in $ServiceList) {
    $Service = $($ServiceList.Service)
    $statService = Invoke-Command -Session $s -ScriptBlock {Get-Service $Service }
    If ($statService.Status -eq "Running"){
        Invoke-Command -Session $s -ScriptBlock { Stop-Service -name $args[0]} -ArgumentList $Service
        Write-Host $Service " stopping"
    }
    If ($statService.StartType -ne "Disabled"){
        Write-Host "Disabling " $Service 
        Invoke-Command -Session $s -ScriptBlock {Set-Service -Name $args[0] -StartupType Disabled} -ArgumentList $Service
    }

}
