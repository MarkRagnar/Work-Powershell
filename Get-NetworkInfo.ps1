# Network Audit Utility by MRH of BMCNetworks
#
#Set Global Variables
$Domain="domain.local"
$ReportPath="C:\Audit"
$DaysInactive = 90 


#Calculated Variables
$RootDSE = Get-ADRootDSE -Server $Domain
$Date = Get-Date
$DC = Get-ADDomainController -Discover -Domain $Domain -Service "PrimaryDC","TimeService"
$timeinactive = (Get-Date).Adddays(-($DaysInactive)) 

$Credentials = Get-Credential


$ErrorActionPreference = 'SilentlyContinue'

#Get Password Policy
$PasswordPolicy = Get-ADObject $RootDSE.defaultNamingContext -Property minPwdAge, maxPwdAge, minPwdLength, pwdHistoryLength, pwdProperties
$PasswordPolicy | Select-Object @{n="PolicyType";e={"Password"}},`

DistinguishedName,`

@{n="minPwdAge";e={"$($_.minPwdAge / -864000000000) days"}},`

@{n="maxPwdAge";e={"$($_.maxPwdAge / -864000000000) days"}},`

minPwdLength,`

pwdHistoryLength,`

@{n="pwdProperties";e={Switch ($_.pwdProperties) {

    0 {"Passwords can be simple and the administrator account cannot be locked out"}

    1 {"Passwords must be complex and the administrator account cannot be locked out"}

    8 {"Passwords can be simple, and the administrator account can be locked out"}

    9 {"Passwords must be complex, and the administrator account can be locked out"}

    Default {$_.pwdProperties}}}} | ConvertTo-Html | Set-Content $ReportPath\PasswordPolicy.html 

#Get Failed Logins
 
 $HTML=@" 
<title>Event Logs Report</title> 
 
BODY{background-color :#FFFFF} 
TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;} 
TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color: ThreeDShadow} 
TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: Transparent} 
 
"@ 
 
$eventsDC= Get-Eventlog security -Computer $DC -InstanceId 4625 -After (Get-Date).AddDays(-7) | 
   Select-Object TimeGenerated,ReplacementStrings | 
   ForEach-Object { 
     New-Object PSObject -Property @{ 
      Source_Computer = $_.ReplacementStrings[13] 
      UserName = $_.ReplacementStrings[5] 
      IP_Address = $_.ReplacementStrings[19] 
      Date = $_.TimeGenerated 
    } 
   } 
    
  $eventsDC | ConvertTo-Html -Property Source_Computer,UserName,IP_Address,Date -head $HTML -body "<H2>Gernerated On $Date</H2>"| 
     Out-File $ReportPath\FailedLogins.html -Append 

#Export AD Users
Get-ADUser -Filter * -Properties * | export-csv $ReportPath\ADusers.csv
Get-ADUser -Filter  'enabled -eq $true' -Properties * | export-csv $ReportPath\EnabledADusers.csv
#Rem Testing time inactive
Get-ADUser -Filter  {'enabled -eq $true' -and {LastLogonDate -lt $timeinactive}} -Properties * | export-csv $ReportPath\InactiveADusers.csv