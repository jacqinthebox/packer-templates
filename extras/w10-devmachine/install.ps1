#New-Item -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Force
New-ItemProperty -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -PropertyType dword -Value 1
Install-Module ISESteroids -Scope CurrentUser -Force
Install-Module PsISEProjectExplorer -Force
Import-Module PsISEProjectExplorer -Force
Add-PsISEProjectExplorerToIseProfile

choco install git --yes --force
choco install git-credential-winstore --yes --force
choco install conemu --yes --force
choco install googlechrome --yes --force
choco install visualstudiocode --yes --force
choco install VisualStudio2015Community --yes --force --packageParameters "--AdminFile https://gist.githubusercontent.com/jacqinthebox/494111cc5e2941e963d1424d15813cf2/raw/2a23194c41d866a7cd8ad8d68efe8a82595dfa70/AdminDeployment.xml"
