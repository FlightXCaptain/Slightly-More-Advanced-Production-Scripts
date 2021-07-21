#Install-Module MSOnline
#This Script has multiple options (See bottom) By default it lists peoples MFA registered phone numbers for emergency purposes #Lockdown
$AzureCredential = Get-AutomationPSCredential -Name 'Powershell'

Connect-MsolService -Credential $AzureCredential

Get-MsolUser -All | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $nul} | Out-Null

$Result=@() 
$users = Get-MsolUser -All
$users | ForEach-Object {
$user = $_
$mfaStatus = $_.StrongAuthenticationRequirements.State 
$methodTypes = $_.StrongAuthenticationMethods 

if ($mfaStatus -ne $null -or $methodTypes -ne $null)
{
if($mfaStatus -eq $null)
{ 
$mfaStatus='Enabled (Conditional Access)'
}
$authMethods = $methodTypes.MethodType
$defaultAuthMethod = ($methodTypes | Where{$_.IsDefault -eq "True"}).MethodType 
$verifyEmail = $user.StrongAuthenticationUserDetails.Email 
$phoneNumber = $user.StrongAuthenticationUserDetails.PhoneNumber
$alternativePhoneNumber = $user.StrongAuthenticationUserDetails.AlternativePhoneNumber
}
Else
{
$mfaStatus = "Disabled"
$defaultAuthMethod = $null
$verifyEmail = $null
$phoneNumber = $null
$alternativePhoneNumber = $null
}
    
$Result += New-Object PSObject -property @{ 
UserName = $user.DisplayName
UserPrincipalName = $user.UserPrincipalName
MFAStatus = $mfaStatus
AuthenticationMethods = $authMethods
DefaultAuthMethod = $defaultAuthMethod
MFAEmail = $verifyEmail
PhoneNumber = $phoneNumber
AlternativePhoneNumber = $alternativePhoneNumber
}
}
#Displays all MFA Info
#$Result | Select UserName,MFAStatus,MFAEmail,PhoneNumber,AlternativePhoneNumber

#List all Enabled Users
$Result | Where {$_.MFAStatus -ne "Disabled"} | Select UserName,MFAStatus | Format-Table

#Export this to CSV
#$Result | Where {$_.MFAStatus -ne "Disabled"} | Select UserName,MFAStatus | Export-csv 'C:\temp\MFA-Status-Export.csv'
#Write-Host 'Export file can be found in C:\temp folder'

#List All Users MFA Phone Number
#$Result | Where {$_.MFAStatus -ne "Disabled"} | Select UserName,PhoneNumber

#$Result | Export-CSV "C:\O365-Users-MFA-Details.csv" -NoTypeInformation -Encoding UTF8