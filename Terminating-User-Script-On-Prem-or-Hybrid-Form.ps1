$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Please enter in your Domain Admin credentials.  Please remember it should be in the form of DOMAIN\username. The second & third prompt for your credentials, it will be for Office365. At that time, please use  username@fqdn.com",0,"Credentials Needed!",0x0)	
$creds = Get-Credential -Username domain\adminaccount -Message 'Enter Domain Password'
$PSDefaultParameterValues = @{"*-AD*:Credential"=$creds}

#CREATES AN EXCHANGE ONLINE SESSION
$UserCredential = Get-Credential -Username admin@example.org.au -Message 'Enter Office365 Password'
$ExchangeSession =  New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Install-Module SharePointPnPPowerShellOnline -Force -Credential $UserCredential
Install-Module MSOnline -Force -Credential $UserCredential

#IMPORT SESSION COMMANDS
Import-PsSession $ExchangeSession  -AllowClobber 
connect-MsolService -Credential $UserCredential
Connect-PNPOnline -Credential $UserCredential -Url 'https://Example-admin.sharepoint.com' 
Connect-SPOService -Url "https://Example-admin.sharepoint.com"

#Notes: PNP v SPO 
#PnP PowerShell Cmdlets works in the context of the current user, where as SPO command runs with the Tenant Admin rights.
#PnP PowerShell Cmdlets connects to the SiteCollection level, where as SPO has the commands to target Tenant level.

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 
	
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Terminated Employee Process Form"
$objForm.Size = New-Object System.Drawing.Size(500,400) 
$objForm.StartPosition = "CenterScreen"
$objForm.MaximizeBox = $False

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$userinput=$UserTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$ticketnumber=$TicketTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$Font = New-Object System.Drawing.Font("Verdana",8,[System.Drawing.FontStyle]::Bold) 
#$objForm.Font = $Font 
#VERSION NUMBER
$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Location = New-Object System.Drawing.Size(450,10) 
$VersionLabel.Size = New-Object System.Drawing.Size(120,20) 
$VersionLabel.Font = $Font 
$VersionLabel.Text = "V1.3"
$objForm.Controls.Add($VersionLabel) 

#OK AND CANCEL BUTTONS
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,320)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$userinput=$UserTextBox.Text;$ticketnumber=$TicketTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()})
$objForm.Controls.Add($OKButton)

#USERNAME LABEL
$UserLabel = New-Object System.Windows.Forms.Label
$UserLabel.Location = New-Object System.Drawing.Size(10,20) 
$UserLabel.Size = New-Object System.Drawing.Size(280,20) 
$UserLabel.Text = "Username of Terminated Employee"
$objForm.Controls.Add($UserLabel) 

#USERNAME TEXT BOX
$UserTextBox = New-Object System.Windows.Forms.TextBox 
$UserTextBox.Location = New-Object System.Drawing.Size(10,40) 
$UserTextBox.Size = New-Object System.Drawing.Size(180,20) 
$objForm.Controls.Add($UserTextBox) 

#DISABLE USER CHECKBOX CONTROL
$DisableUserCheckbox = New-Object System.Windows.Forms.Checkbox 
$DisableUserCheckbox.Location = New-Object System.Drawing.Size(220,30) 
$DisableUserCheckbox.Size = New-Object System.Drawing.Size(120,40)
$DisableUserCheckbox.Text = "Disable The User?"
$objForm.Controls.Add($DisableUserCheckbox)

#FORWARD EMAIL LABEL
$FowardEmailLabel = New-Object System.Windows.Forms.Label
$FowardEmailLabel.Location = New-Object System.Drawing.Size(10,80) 
$FowardEmailLabel.Size = New-Object System.Drawing.Size(280,20)
$FowardEmailLabel.Text = "Forward Email? If Yes, Type In Email Address"
$objForm.Controls.Add($FowardEmailLabel)

#FORWARD EMAIL TEXT BOX
$ForwardingTextBox = New-Object System.Windows.Forms.TextBox 
$ForwardingTextBox.Location = New-Object System.Drawing.Size(10,100) 
$ForwardingTextBox.Size = New-Object System.Drawing.Size(180,40) 
$objForm.Controls.Add($ForwardingTextBox) 

#ENTER TICKET NUMBER TEXT LABEL
#$TicketLabel = New-Object System.Windows.Forms.Label
#$TicketLabel.Location = New-Object System.Drawing.Size(10,150) 
#$TicketLabel.Size = New-Object System.Drawing.Size(80,20)
#$TicketLabel.Text = "Ticket Number"
#$objForm.Controls.Add($TicketLabel)

#$TicketTextBox = New-Object System.Windows.Forms.TextBox 
#$TicketTextBox.Location = New-Object System.Drawing.Size(10,170) 
#$TicketTextBox.Size = New-Object System.Drawing.Size(40,250) 
#$objForm.Controls.Add($TicketTextBox) 

#CANCEL BUTTONS
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(350,320)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close(); $cancel = $true})
$objForm.Controls.Add($CancelButton)

$objForm.Topmost = $True
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
if ($cancel) {return}
#$OKButton.Add_Click({$userinput=$UserTextBox.Text;$ticketnumber=$TicketTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()})
#$CancelButton.Add_Click({$objForm.Close()})

#COMMON GLOBAL VARIABLES
$disableusercheckbox=$DisableUserCheckbox.Checked
$userinput=$UserTextBox.Text
$forwardemail=$ForwardingTextBox.Text
#$ticketnumber=$TicketTextBox.Text

$Month = Get-Date -format MM
$Day = Get-Date -format dd
$Year = Get-Date -format yyyy

If ($OKButton.Add_Click) {

########
#ACTIVE DIRECTORY ACTIONS
#########

#GET USERS MANAGER FOR ONEDRIVE ACCESS BEFORE THE FIELD IS CLEARED And their UPN
$Manager = Get-ADUser -Identity $userinput -Properties '*' | Select -ExpandProperty Manager
$ManagerUPN= Get-ADUser $Manager |Select -ExpandProperty UserPrincipalName

#DISABLE THE USER
If ($disableusercheckbox -eq $true)
{
  Disable-ADAccount -Identity $userinput
  $disabled = $userinput + " has been disabled"
} else { 
	$notdisabled = $userinput + " has not been disabled at this time" 
}

#GETS ALL GROUPS USER WAS PART OF BEFORE BLOWING THEM OUT
    $User = $userinput
    $List=@()
    $Groups = Get-ADUser -Identity $User -Properties * | select -ExpandProperty memberof
    foreach($i in $Groups){
    $i = ($i -split ',')[0]
    $List += "`r`n" + ($i -creplace 'CN=|}','')
    }
    
#BLOW OUT GROUPS OF USER EXCEPT DOMAIN USERS
(get-aduser $userinput -properties memberof).memberof|remove-adgroupmember -member $userinput -Confirm:$False

#SETS THE USERS TITLE,COMPANY/MANAGER TO DISABLED
set-aduser -identity $userinput -description "Disabled $Day/$Month/$Year"
set-aduser -identity $userinput -company $null
set-aduser -identity $userinput -manager $null
set-aduser -identity $userinput -department $null
set-aduser -identity $userinput -title $null
set-aduser -identity $userinput -office $null
set-aduser -identity $userinput -OfficePhone $null
set-aduser -identity $userinput -HomePage $null

#CHANGES USERS PASSWORD TO A RANDOMLY GENERATED ONE
Add-Type -AssemblyName 'System.Web'
$PASSWORD1 = [System.Web.Security.Membership]::GeneratePassword(15,0)
$newpwd = ConvertTo-SecureString -String $PASSWORD1 -AsPlainText -Force
Set-ADAccountPassword $userinput -NewPassword $newpwd -Reset

#MOVES THE USER TO DISABLED USERS
Get-ADUser $userinput -Credential $creds | Move-ADObject -TargetPath #"OU=Terminated Users,OU=Users,DC=example,DC=example"             

#HIDES USER FROM GLOBAL ADDRESS BOOK
$user = Get-ADUser $userinput -properties *
$user.msExchHideFromAddressLists = "True"
Set-ADUser -Instance $user
#Set-Mailbox $userinput -HiddenFromAddressListsEnabled $true

Start-Sleep -s 3

########
#OFFICE 365 ACTIONS
#########

#Gets Full UPN Based on AD Username to get around us having multiple Domains for next step
$UserUPN= Get-ADUser $userinput |Select -ExpandProperty UserPrincipalName

#REMOVES THE USER LICENSE
$userArray = Get-MsolUser -UserprincipalName $userUPN | where {$_.isLicensed -eq $true}
for ($i=0; $i -lt $userArray.Count; $i++)
{
Set-MsolUserLicense -UserPrincipalName $userArray[$i].UserPrincipalName -RemoveLicenses $userArray[$i].licenses.accountskuid
}

#CONVERTS THE USERMAILBOX TO A SHARED MAILBOX (Dont Suggest)
Set-Mailbox $userinput -Type shared

#SETS THE EMAIL FORWARD
If ($forwardemail){
$forwarded = $userinput + " email is now being forwarded to " + $forwardemail
Set-Mailbox $userinput -ForwardingAddress $forwardemail -DeliverToMailboxAndForward $true 
} else { $notforwarded = "No email forwards at this time"}

#ONEDRIVE SECTION - Changing Owner of terminated users onedrive to their manager
$OnedriveUrl = Get-PnPUserProfileProperty -Account $UserUPN | select PersonalUrl
$Site = Get-SPOSite -Identity $OnedriveUrl.PersonalUrl.TrimEnd('/')
Set-SPOUser -Site $Site.Url -LoginName $ManagerUPN -IsSiteCollectionAdmin $true

#REMOVES THE SESSION
Remove-PSsession $ExchangeSession 

#SENDING MAIL TO MANAGER ABOUT ONEDRIVE EXPIRES IN 30 DAYS
$Password = #''
$Mailbox = #''
$Subject = 'Important Terminated User Onedrive Access 30 Days'
$To = $ManagerUPN
$body = $userinput+" has been terminated in our System." + '

Please save any of their Onedrive Files elsewhere before it is Archived in 30 days 

' + $OneDriveURL.PersonalUrl + '

This is an Automated Email please do not Respond

ICT Team'

$pass = $Password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Mailbox,$pass)
Send-MailMessage -To $To -SmtpServer smtp.office365.com -Credential $cred -From $Mailbox -Subject $Subject -UseSsl -body ($body | Out-String)

#Sending Email to servicedesk for Reminder to Exit user in 30 days
$Subject = 'Powershell Exit User Reminder Email'
$To = #''
$body0 = ($body3, $body4)
$body3 = $userinput + " Password has been set to" + $PASSWORD1 + '
'
$body4 = $Groups

$cred = New-Object System.Management.Automation.PSCredential($Mailbox,$pass)
Send-MailMessage -To $To -SmtpServer smtp.office365.com -Credential $cred -From $Mailbox -Subject $Subject -UseSsl -body ($body0 | Out-String)

Start-Sleep -s 2

}