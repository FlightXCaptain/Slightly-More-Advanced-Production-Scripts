$VerbosePreference='Continue'
$FDApiKey = Get-AutomationVariable -Name "FreshService API"
$AccessToken = Get-AutomationVariable -Name "Microsoft Access Token"

#Prep
$pair = "$($FDApiKey):$($FDApiKey)"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$FDHeaders = @{ Authorization = $basicAuthValue }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

#Api Endpoints Used
$Uri = "https://FSUrl.freshservice.com/api/v2/objects/#########/records?page_size=100"
$url = "https://graph.microsoft.com/beta/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"

#List Initializations
$FSTeams = @()
$MSTeams = @()

#Getting FS Teams in Custom Object
$response2 = Invoke-RestMethod -Uri $Uri -Headers $FDHeaders -ContentType "application/json" -Method Get | ConvertTo-Json | ConvertFrom-Json
Foreach ($re in $response2.records.data) {
        $Index = $re.IndexOf("team_name=")
        $sub = $re.Substring($Index).TrimEnd("}")
        $Name = $sub.TrimStart("team_name=")
        $Index2 = $re.IndexOf("bo_display_id=")
        $sub2 = $re.Substring($Index2)
        $sub3 = $sub2.TrimStart("bo_display_id=")
        $Index3 = $sub3.IndexOf(";")
        $Id = $sub3.Substring(0,$Index3)
        $FSTeams += New-Object -TypeName PSObject -Property @{Name=$Name; ID=$Id}
}

#Getting MS Teams in MS Environment
$response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $AccessToken"}
foreach($r in $response.value){ 
    if($r.resourceProvisioningOptions -eq 'Team'){
        $MSTeams += $r.displayName
    }
}

#Comparing & Syncing Lists
Compare-Object -ReferenceObject $MSTeams -DifferenceObject $FSTeams.Name -IncludeEqual | 
ForEach -Begin {
    } -Process {
       if ($_.SideIndicator -eq '<='){
           Write-Host $_.InputObject -ForegroundColor Green
           $Body = @{data=@{team_name=$_.InputObject}} | ConvertTo-Json
           Invoke-RestMethod -Uri $Uri -Headers $FDHeaders -ContentType "application/json" -Method POST -Body $Body | ConvertTo-Json | Out-Null
       } if ($_.SideIndicator -eq '=>') {
           Write-Host $_.InputObject -ForegroundColor Red
           $N = $FSTeams -match $_.InputObject | Select id
           $NI = $N.id
           Invoke-RestMethod -Uri "https://FSUrl.freshservice.com/api/v2/objects/#########/records/$NI" -Headers $FDHeaders -ContentType "application/json" -Method DELETE -ErrorAction SilentlyContinue | ConvertTo-Json 
       } if ($_.SideIndicator -eq '==') {
           Write-Host $_.InputObject -ForegroundColor Cyan
       }
}