#Param (
#    [string]$Group
#)

#Uninstall-Module AzureAD
#Install-Module AzureADPreview -Force

$AzureCredentials = Get-AutomationPSCredential -Name 'Powershell'

#Connect-AzureAD -Credential $AzureCredentials

Get-AzureADGroup -SearchString $Group

#Disable Group Creation (on which a Team rely)
$Template = Get-AzureADDirectorySettingTemplate | where {$_.DisplayName -eq 'Group.Unified'}
$OldTemplateID = Get-AzureADDirectorySetting | where {$_.DisplayName -eq 'Group.Unified'}
$Setting = $Template.CreateDirectorySetting()

    if ($Template -eq $null) {
        New-AzureADDirectorySetting -DirectorySetting $Setting 
    }
    else {
        Set-AzureADDirectorySetting -DirectorySetting $Setting -Id $OldTemplateID.id
    }

$Setting = Get-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ).id
$Setting["EnableGroupCreation"] = $False

#Enable your AAD Group to group Creation
$Setting["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $Group).objectid
Set-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ).id -DirectorySetting $Setting
