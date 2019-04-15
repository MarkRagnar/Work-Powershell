
#Site Variables
$OU 		= "OU=Current,OU=Users,,DC=com"
$EmailDomain = "@domain.com"
$UPNDomain = $EmailDomain
$streetaddress = "Address"
$city       = "Vancouver"
$zipcode    = "V6E 1c1"
$state      = "British Columbia"
# $jobtitle   = $User.jobtitle


#Passgen Function
# From http://sigkillit.com/tag/exchange-365/
Function Generate365PW
{
	Param($max = 1)
	For ($i = 0; $i -lt $max; $i++){
        $pw = Get-Random -Count 1 -InputObject ((33..47)+(58..64)+(123..126)) | % -begin {$UC=$null} -process {$UC += [char]$_} -end {$UC}
        $pw += Get-Random -Count 1 -InputObject ((65..72)+(74..75)+(77..78)+(80..90)) | % -begin {$UC=$null} -process {$UC += [char]$_} -end {$UC}
        $pw += Get-Random -Count 1 -InputObject (97,101,105,111,117,121) | % -begin {$LC=$null} -process {$LC += [char]$_} -end {$LC}
		$pw += Get-Random -Count 2 -InputObject (97..122) | % -begin {$LC=$null} -process {$LC += [char]$_} -end {$LC}
		$pw += Get-Random -Count 4 -InputObject (48..57) | % -begin {$NB=$null} -process {$NB += [char]$_} -end {$NB}
		write-output $pw
	}
}


# Import active directory module for running AD cmdlets
Import-Module activedirectory
  


	
    $Firstname 	= Read-Host -Prompt "First Name"
    $Lastname = Read-Host -Prompt "Last Name"
    $UserName = $Firstname.Substring(0,1) + $Lastname



	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exists in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable 
        #Determine Variables

        
        $Password = Generate365PW
    
        $DisplayName = "$Firstname $Lastname"
        # $Description = $User.Description
        $email = $UserName + $EmailDomain
        $UPN   = $Username + $UPNDomain


        
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName $UPN `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName $DisplayName `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
        
       Set-ADUser $Username -Add @{ProxyAddresses="SMTP:$($email)"}

      
       Write-Host  "User $DisplayName created with account $UserName and Password $Password"
	}