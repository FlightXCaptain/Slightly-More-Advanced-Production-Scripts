$AccessToken = Get-AutomationVariable "MSAccessToken"

#Teams Webhook
$URI = 'create a teams channel webhook'

#Form request headers with the acquired $AccessToken
$headers = @{"Authorization"="Bearer $AccessToken"}
 
#This request get users list with signInActivity.
$ApiUrl = "https://graph.microsoft.com/beta/users?top=999&select=displayName,userPrincipalName,signInActivity,userType,assignedLicenses,id"

$ExclusionUPNS = [pscustomobject] @{
'userprincipalname' =
    "exclude system accounts email here."
}

$Response = Invoke-WebRequest -Method GET -Uri $ApiUrl -ContentType "application\json" -Headers $headers 
$Response1 = $Response.Content | ConvertFrom-json
$Result = $Response1.value
$result1 = $Result | Where {(Compare-Object -ReferenceObject $Result.userprincipalname -DifferenceObject $ExclusionUPNS -Property userPrincipalName).sideIndicator -eq '<='} | FT
$InactiveUsers = @()
ForEach ($User in $Result) {
$DisplayName = $User.displayName
$UserPrincipalName = $User.userPrincipalName
$id = $User.id
$LastSignInDateTime = if($User.signInActivity.lastSignInDateTime) { [DateTime]$User.signInActivity.lastSignInDateTime } Else {$null}
$DaysSinceLastLogin = if($LastSignInDateTime -ne $null) {(New-TimeSpan -start(Get-Date $User.signInActivity.lastSignInDateTime) -end(get-date)).Days}
#$IsStale = if($DaysSinceLastLogin -gt "90"){$true} else {$false}

$IsStale = $false
$IsStale = ($DaysSinceLastLogin -gt "90")

$IsLicensed  = if ($User.assignedLicenses.Count -ne 0) { $true } else { $false }
$IsGuestUser  = if ($User.userType -eq 'Guest') { $true } else { $false }
    If ($IsStale -eq $true) {
    
            $InactiveUsers1 = [psCustomObject] @{
            User         = $DisplayName
            UPN          = $UserPrincipalName
            ObjectID     = $id
            IsStale      = $IsStale
            LastLogon    = $LastSignInDateTime
            DaysSinceLastLogon = $DaysSinceLastLogin
            #UserIsStaleAfterThisManyDays = "90"
            }
            $JSON = @{
              "@type"    = "MessageCard"
              "@context" = "<http://schema.org/extensions>"
              "title"    = "User is now Stale"
              "text"     = "This User has not logged in for over 90 days"
              "sections" = @(
                @{
                  "activityTitle"    = $InactiveUsers1.User
                  "activitySubtitle" = $InactiveUsers1.UPN/n $InactiveUsers1.ObjectID/n $InactiveUsers1.LastLogon
                  "activityText"     = 'Descriptive text for the activity.'
                }
              )
            } | ConvertTo-JSON
            $InactiveUsers += $InactiveUsers1
            $JSON = $InactiveUsers | ConvertTo-Json -Depth 99
              $Params = @{
              "URI"         = $URI
              "Method"      = 'POST'
              "Body"        = $JSON
              "ContentType" = 'application/json'
            }

               Invoke-RestMethod @Params

        $InactiveUsers | FT
    }
}


