Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$Hostname = Hostname
if (($Hostname -like 'LT-*') -or ($Hostname -like 'DT-*') ) 
{
Write-Host "Does not need Renaming"
}
else 
{
Function Detect-Laptop
{
Param( [string]$computer = “$hostname” )
$isLaptop = $false
#The chassis is the physical container that houses the components of a computer. Check if the machine's chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook
if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
{ $isLaptop = $true }
#Shows battery status , if true then the machine is a laptop.
if(Get-WmiObject -Class win32_battery -ComputerName $computer)
{ $isLaptop = $true }
$isLaptop
}
If(Detect-Laptop) {
$Serial = Get-WmiObject win32_bios | select Serialnumber 
$LT = 'LT-'
$Computername = $LT+$Serial.Serialnumber
Write-Host $Computername
Rename-Computer $Computername
}
else {
$Serial = Get-WmiObject win32_bios | select Serialnumber 
$DT = 'DT-'
$Computername = $DT+$Serial.Serialnumber
Write-Host $Computername
Rename-Computer $Computername
}
}
Set-ExecutionPolicy Restricted -Force