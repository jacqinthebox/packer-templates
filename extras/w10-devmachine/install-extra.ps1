Function Add-Software {

param(

    [Parameter(Mandatory = $true)]
    [ValidateSet('small','medium','large','x-large')]
    [string]$installtype,
    [Parameter(Mandatory = $false)]
    [bool]$virtualmachine
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
choco install visualstudiocode -force -yes
choco install sumatrapdf -force -yes
choco install sumatrapdf.install -force -yes

Install-Module Posh-Git -Force
Install-Module Oh-My-Posh -Force
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

Set-ExecutionPolicy restricted
}
