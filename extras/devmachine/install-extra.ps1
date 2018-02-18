Function Add-Software {

param(
    [Parameter(Mandatory = $false)]
    [bool]$InstallVisualStudio
)

Set-ExecutionPolicy Bypass
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
Install-PackageProvider -Name Nuget -Force

choco install visualstudiocode -force -yes
choco install git -force -yes
choco install notepadplusplus -force -yes

choco install 7zip.install  -force -yes
choco install 7zip.commandline -force -yes
choco install firefox -force -yes
choco install git -force -yes
choco install sumatrapdf -force -yes
choco install sumatrapdf.install -force -yes
choco install conemu -force -yes

Install-Module Posh-Git -Force
Install-Module Oh-My-Posh -Force
Install-Module ISESteroids -Scope CurrentUser -Force

if ( $InstallVisualStudio -eq $True ) {
    choco install visualstudio2017enterprise  -force -yes
    choco install sql-server-management-studio -force -yes
    }
}
