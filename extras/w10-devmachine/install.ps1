#New-Item -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Force
New-ItemProperty -path "registry::hklm\software\policies\microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -PropertyType dword -Value 1
Install-Module ISESteroids -Scope CurrentUser

choco install git --yes --force
choco install git-credential-winstore --yes --force
choco install conemu --yes --force
choco install googlechrome --yes --force
choco install visualstudiocode --yes --force
