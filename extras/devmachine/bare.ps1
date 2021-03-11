# Set-ExecutionPolicy RemoteSigned -Confirm:$false -Force
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
Install-PackageProvider -Name Nuget -Force

$software = @(
    'googlechrome',
    'firefox'
)


foreach ($s in  $software) {
    choco install $s -yes
}

Install-Module posh-git -Scope CurrentUser -Force
Install-Module oh-my-posh -Scope CurrentUser -Force

Invoke-WebRequest https://github.com/jacqinthebox/packer-templates/blob/master/extras/devmachine/Meslo%20LG%20M%20DZ%20Regular%20for%20Powerline.ttf?raw=true -OutFile ~\Desktop\Meslo.ttf
