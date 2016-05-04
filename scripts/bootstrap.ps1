# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# Spin through all the network locations and if they are set to Public, set them to Private
# using the INetwork interface:
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# For more info, see:
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx

# Network location feature was only introduced in Windows Vista - no need to bother with this
# if the operating system is older than Vista
if([environment]::OSVersion.version.Major -lt 6) { return }

# You cannot change the network location if you are joined to a domain, so abort
if(1,3,4,5 -contains (Get-WmiObject win32_computersystem).DomainRole) { return }

# Before anything else create the log output folder
Write-Host "Copy unattend.xml to c:\logs"
New-Item C:\Windows\Panther\Unattend -Type Directory
New-Item c:\Logs -Type Directory
Copy-Item a:\unattend.xml C:\Logs\

#disable LUA
#New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

# Get network connections

$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
$connections = $networkListManager.GetNetworkConnections()

$connections |foreach {
    Write-Host "Setting network config"
    $_.GetNetwork().GetName() + 'category was previously set to' + $_.GetNetwork().GetCategory() | Out-File c:\logs\logfile.txt
    $_.GetNetwork().SetCategory(1)
    $_.GetNetwork().GetName() + 'change to ' + $_.GetNetwork().GetCategory() | Out-File C:\Logs\logfile.txt -Append
}

function Enable-WinRM {
    Write-Host "Enable WinRM"
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="Open Port 5985" dir=in action=allow protocol=TCP localport=5985

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

net stop winrm
sc.exe config winrm start= auto
net start winrm
 
}

Enable-WinRM
