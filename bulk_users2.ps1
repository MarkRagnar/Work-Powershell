# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv C:\Temp\bulk_users.csv

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$UserName 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
    $Lastname 	= $User.lastname
    $DisplayName = $User.Displayname
	$OU 		= "OU=Current,OU=UsersDC=local"
    $email      = $User.ProxyAddress
    $streetaddress = "400 - AVE "
    $city       = "City"
    $zipcode    = "V3L "
    $state      = "British Columbia"
    $country    = "Canada"
    #$telephone  = $User.telephone
    #$jobtitle   = $User.jobtitle
    $company    = "Company"
    # $department = $User.department
    $Password = $User.Password
    $ProxyAddresses = "SMTP:"$User.ProxyAddress


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@winadpro.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
}
