# Script to bootstrap a Vagrant Win10 development box

param(
    [ValidateSet('small','medium','large','x-large')]
    [string]$installtype,
    [Parameter(Mandatory = $true)]
    [bool]$vm = $True
)

Set-ExecutionPolicy Bypass
New-Item -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Force
New-ItemProperty -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -PropertyType dword -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
Install-PackageProvider -Name Nuget -Force

choco install notepadplusplus -force -yes
choco install 7zip.install  -force -yes
choco install 7zip.commandline -force -yes
choco install firefox -force -yes
choco install git -force -yes
choco install visualstudiocode -force -yes
choco install sumatrapdf -force -yes
choco install sumatrapdf.install -force -yes
Install-Module Posh-Git -Force
Install-Module ISESteroids -Scope CurrentUser -Force


if ($installtype -eq 'medium' -or 'large' -or 'x-large') {
    choco install googlechrome -force -yes
    choco install conemu -force -yes
}

if ($installtype -eq 'large' -or 'x-large') {
    choco install listary -force -yes
    choco install keepass -force -yes
    choco install greenshot -force -yes
       
}

if ($installtype -eq  'x-large') {
    choco install visualstudio2017professional -force -yes
    choco install sql-server-management-studio -force -yes
}

if ($vm -eq $false) {
   choco install dropbox -force -yes
   choco install googledrive -force -yes
   choco install virtualbox -force -yes
   choco install vagrant -force -yes
}

#choco upgrade all
