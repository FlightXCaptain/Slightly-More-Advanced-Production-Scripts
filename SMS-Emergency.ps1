#This Script was for an emergency SMS with twillio for staff at different Sites/Departments through azure automation

#Install-Module MSOnline
Param (
    [Parameter(Mandatory=$true)]
    [string]$Message,
    [Parameter(Mandatory=$true)]
    [validate('Department1','Department2','Department3','Department1&2','All Departments')]
    [string]$Entity
)
$AzureCredential = Get-AutomationPSCredential -Name 'Powershell'

Connect-MsolService -Credential $AzureCredential

if($Entity -match "Department1"){
    $Data = Get-MsolUser -EnabledFilter EnabledOnly | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $null -and $_.department -eq "Department1"}
}
if($Entity -match "Department2"){
    $Data = Get-MsolUser -EnabledFilter EnabledOnly | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $null -and $_.department -eq "Department2"}
}
if($Entity -match "Department3"){
    $Data = Get-MsolUser -EnabledFilter EnabledOnly | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $null -and $_.department -eq "Department3"}
}
if($Entity -match "Department2&3"){
    $Data = Get-MsolUser -EnabledFilter EnabledOnly | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $null -and $_.department -eq "Department2" -or $_.department -eq "Department3"}
}
if($Entity -match "Department1&2&3"){
    $Data = Get-MsolUser -EnabledFilter EnabledOnly | Where {$_.StrongAuthenticationMethods -ne $null -or $_.StrongAuthenticationRequirements.State -ne $null -and $_.department -eq "Department3" -or $_.department -eq "Department2" -or $_.department -eq "Department1"}
}

    $Result=@() 
    $users = $Data
    $users | ForEach-Object {
    $user = $_
    $mfaStatus = $_.StrongAuthenticationRequirements.State 
    $methodTypes = $_.StrongAuthenticationMethods
    if ($mfaStatus -ne $null -or $methodTypes -ne $null)
    {
    if($mfaStatus -eq $null)
    { 
    $mfaStatus = 'Enabled (Conditional Access)'
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
    $Result1 = $Result | Where {$_.MFAStatus -ne "Disabled"} | Select UserName,PhoneNumber -First 500
    $PhoneNumbers = ""
    ForEach ($Member in $Result1){$PhoneNumbers += $Member.PhoneNumber+','}
    $PhoneNumbers2 = ForEach ($PHN in $PhoneNumbers){$PHN -replace " 0","" -replace " ",""}
    $PhoneNumbers3 = $PhoneNumbers2.Split(",")
    Write-Output $Result1 | Select UserName,PhoneNumber

#Twillio Connection
$TwillioSid = Get-AutomationVariable -Name "TwillioSid" 
$TwillioToken = Get-AutomationVariable -Name "TwillioToken" 
$TwillioNumber = "with country code"
$TwilioUri = Get-AutomationVariable -Name "TwillioUri" 

$p = $TwillioToken | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($TwillioSid, $p)

ForEach ($Number in $PhoneNumber3) {
    $APIBody = @{ 
        To = $Number;
        From = $TwillioNumber;
        Body = $Message
    }
Invoke-WebRequest -Uri $TwilioUri -Body $APIBody -UseBasicParsing -Method POST -Credential $credential | ConvertFrom-Json | Select sid,body
} 