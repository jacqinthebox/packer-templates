<# set autologon
Write-Host 'Setting autologon'
'Setting autologon' | Out-File c:\logs\logfile.txt -append

$secpasswd = ConvertTo-SecureString 'vagrant' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('vagrant', $secpasswd)

Set-ExecutionPolicy Bypass -Force
$WinlogonPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
Remove-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon
Remove-ItemProperty -Path $WinlogonPath -Name DefaultUserName
#>

#enable RDP
'Enabling RDP' | Out-File c:\logs\logfile.txt -append
Write-Host 'Enabling RDP'
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 0 /f


'Installing Guest Additions' | Out-File c:\logs\logfile.txt -append
Write-Host 'Installing Guest Additions'
& cmd /c certutil -addstore -f 'TrustedPublisher' A:\oracle-cert.cer
& E:\VBoxWindowsAdditions.exe /S

Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus'  -Name  'GeneralizationState' -Value 7

Write-Host 'Sdelete things'

Copy-Item a:\sdelete.exe c:\logs
& cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
& cmd /c C:\logs\sdelete.exe -z C:

Write-Host 'Done'
