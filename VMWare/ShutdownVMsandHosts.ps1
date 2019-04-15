#This Script connects to a vCenter Server and shutsdown all VMs and hosts.

Param (
    [Parameter(Mandatory=$true)]
    [string]$VCenter
)
#Load PowerCLI
Import-Module VMware.PowerCLI
#Connect to vCenter, get VMs and hosts

Connect-VIServer $VCenter
$Hosts=Get-VMhost 
$vmservers=Get-VM | Where-Object {($_.powerstate -eq "PoweredOn") -and ($_.Name -notcontains "vmware") }
$VCenter= Get-VM | Where-Object {$_.Name -contains "vmware" }
$vmservers | select Name | export-csv c:\MyScripts\servers.csv -NoTypeInformation
#$vmservers| Shutdown-VMGuest
#Wait for Guests to shutdown

 