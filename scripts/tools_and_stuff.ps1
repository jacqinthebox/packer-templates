# add your customizations here, e.g. install Chocolatey

# Sysprep script until I have a better solution
Write-Host "Add script to desktop and c:\scripts to perform a sysprep."
$sysprepCmd = @"
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/Unattend/unattend.xml /reboot
"@

Set-Content -path "C:\Scripts\sysprep.cmd" -Value $sysprepCmd
if (Test-Path "$env:windir\explorer.exe") {
  Set-Content -path "C:\Users\Vagrant\Desktop\sysprep.cmd" -Value $sysprepCmd
}

# add a rearm script
Write-Host "Add rearm script to desktop and c:\scripts to extend the trial."
$rearmCmd = @"
slmgr -rearm
pause
"@

Set-Content -path "C:\Scripts\extend-trial.cmd" -Value $rearmCmd
if (Test-Path "$env:windir\explorer.exe") {
  Set-Content -path "C:\Users\Vagrant\Desktop\extend-trial.cmd" -Value $rearmCmd
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
