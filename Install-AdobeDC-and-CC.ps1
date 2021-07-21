Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
#Installs Adobe DC and Creative Cloud Console to users computers. Setup to install from link I suggest putting them in azure storage for reliability then linking them in.
Start-Job -Name 'temp' -ScriptBlock {
    $testpath = Test-Path C:\temp 
    if ($testpath -eq $false) {
        New-Item -Path 'C:\temp' -ItemType Directory
    }else {
        Write-Output "File Already Exists"
    } 
} | Wait-Job

$Detect_CC = Test-Path 'C:\Program Files\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe'
    if ($Detect_CC -eq $false){
        Start-Job -Name "DownloadingCC" -ScriptBlock {
            Invoke-WebRequest -Uri '#AdobeCC Download Link Here' -OutFile 'C:\temp\CC.zip' 
        } | Wait-Job
        
        Start-Job -Name 'InstallingCC' -Scriptblock {      
            Expand-Archive -Path 'C:\temp\CC.zip' -DestinationPath 'C:\temp' -Force 
            Start-Sleep -Seconds 5
            Start-Process -FilePath 'C:\temp\Creative Cloud\Build\Creative Cloud.msi' -ArgumentList "/quiet", "/norestart" -Wait
            Write-Output "Adobe CC Installed"
            } | Wait-Job
    }
    else {
        Write-Output "Adobe CC Already Exists Download Aborted"
    }
$Detect_DC = Test-Path 'C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe'
    if ($Detect_DC -eq $false){
        Start-Job -Name "DownloadingDC" -ScriptBlock {
            Invoke-WebRequest -Uri '#AdobeDC Download Link Here' -OutFile 'C:\temp\AdobeReader.exe'
        } | Wait-Job 
            
        Start-Job -Name 'InstallingDC' -Scriptblock {
            Start-Process -FilePath 'C:\temp\AdobeReader.exe' -ArgumentList "/sAll", "/rs", "/msi EULA_ACCEPT=YES" -PassThru -Wait
            Write-Output "Adobe DC Installed"
            } | Wait-Job
    }
    else { 
        Write-Output "Adobe DC Already Exists Download Aborted"
    }

Remove-Item 'C:\temp' -Recurse -Force