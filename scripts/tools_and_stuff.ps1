# add your customizations here in this script.
# e.g. install Chocolatey
if (Test-Path "$env:windir\explorer.exe") {
Invoke-Webrequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

# adding a syscrep script to c:\scripts. This will set the winrm service to start manually
# https://github.com/mwrock/packer-templates/issues/49
Write-Host "Add sysprep script to c:\scripts to call when Packer performs a shutdown."
$SysprepCmd = @"
sc config winrm start=demand
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/Unattend/unattend.xml /quiet /shutdown
"@

Set-Content -path "C:\Scripts\sysprep.cmd" -Value $SysprepCmd

# we need to set the winrm service to auto upon first boot
# https://technet.microsoft.com/en-us/library/cc766314(v=ws.10).aspx
$SetupComplete = @"
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm
"@

New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force
Set-Content -path "C:\Windows\Setup\Scripts\SetupComplete.cmd" -Value $SetupComplete

# rearm script to exend the trial
Write-Host "Add rearm script to desktop and c:\scripts to extend the trial."
$rearmCmd = @"
slmgr -rearm
pause
"@

Set-Content -path "C:\Scripts\extend-trial.cmd" -Value $RearmCmd
if (Test-Path "$env:windir\explorer.exe") {
  Set-Content -path "C:\Users\Vagrant\Desktop\extend-trial.cmd" -Value $RearmCmd
}

# Installing Guest Additions or Parallels tools
Write-Host 'Installing Guest Additions or Parallels Tools'

if (Test-Path d:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive with VBoxWindowsAdditions"
  & d:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
}
if (Test-Path e:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive with VBoxWindowsAdditions"
  & E:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
}

if (Test-Path c:\users\vagrant\prl-tools-win.iso) {
  Write-Host "Mounting Drive with Parallels Tools"
  $volume = Mount-DiskImage -PassThru C:\Users\vagrant\prl-tools-win.iso
  $drive = (Get-Volume -DiskImage $volume).DriveLetter
  $letter = $drive + ":"
  Write-Host "Installing tools"
  & $letter\PTAGENT.EXE /install_silent
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
}
