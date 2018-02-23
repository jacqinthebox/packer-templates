# ugly BizTalk installation script for dev environment on evaluation software
# assuming Vagrant & Choco

$OdtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_8529.3600.exe"
$SqlIsoUrl = "https://s3-eu-west-1.amazonaws.com/freeze/SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
$SqlConfigurationUrl = "https://raw.githubusercontent.com/jacqinthebox/biztalkinstall/master/ConfigurationFile.ini"
$BizTalkUrl = "http://care.dlservice.microsoft.com/dl/download/6/B/C/6BCBE623-03A5-42AC-95AC-2873B68D10B9/BTS2016Evaluation_EN.iso"
$SqlUser = "Vagrant"


$ParametersPath = "C:\Parameters"
New-Item -ItemType directory -Path $ParametersPath -Force
New-Item -ItemType directory -Path c:\Install -Force

$SqlUser = "$env:computername\$SqlUser"
Set-Content -path "$ParametersPath\sqluser.txt" -Value $SqlUser
Set-Content -path "$ParametersPath\nodename.txt" -Value $env:computername
Set-Content -path "$ParametersPath\odturl.txt" -Value $OdtUrl


choco install sql-server-management-studio -force -yes
choco install visualstudio2015community -force -yes
choco install soapui -force -yes

# Windows Features
@("Web-Server",
    "Web-Http-Errors",
    "Web-App-Dev",
    "Web-Asp-Net",
    "Web-Net-Ext",
    "Web-ASP",
    "Web-CGI",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Includes",
    "Web-Basic-Auth",
    "Web-Windows-Auth",
    "Web-Mgmt-Compat",
    "Web-Metabase",
    "Web-WMI",
    "Web-Lgcy-Scripting",
    "Web-Lgcy-Mgmt-Console"
)| Add-WindowsFeature


# DTC
Install-Dtc
Set-DtcNetworkSetting -InboundTransactionsEnabled:$True -OutboundTransactionsEnabled:$True -AuthenticationLevel:NoAuth -LUTransactionsEnabled:$True -Confirm:$false

# Excel
$excel = @"
<Configuration>
<Add SourcePath="c:\install\odt" OfficeClientEdition="32">
<Product ID="O365ProPlusRetail">
<Language ID="en-us" />
<ExcludeApp ID="Access" />
<ExcludeApp ID="Groove" />
<ExcludeApp ID="InfoPath" />
<ExcludeApp ID="Lync" />
<ExcludeApp ID="OneDrive" />
<ExcludeApp ID="OneNote" />
<ExcludeApp ID="Outlook" />
<ExcludeApp ID="PowerPoint" />
<ExcludeApp ID="Project" />
<ExcludeApp ID="Publisher" />
<ExcludeApp ID="SharePointDesigner" />
<ExcludeApp ID="Visio" />
<ExcludeApp ID="Word" />
</Product>
</Add>
<Display Level="None" AcceptEULA="TRUE" />  
</Configuration>
"@
Set-Content -path "c:\install\excel.xml" -Value $excel  


New-Item -ItemType Directory c:\Install\odt -force
Invoke-WebRequest $OdtUrl -OutFile C:\install\officedeploymenttool.exe
Start-Sleep -s 10

set-location c:\install
$preArglist = '/quiet /extract:c:\install'
Start-Process -FilePath c:\install\officedeploymenttool.exe $preArglist -Wait -NoNewWindow

$arglist = '/download excel.xml'
Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist -Wait -NoNewWindow

set-location c:\install
$arglist = '/configure excel.xml'
Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist -Wait -NoNewWindow


# SQL
$source = $SqlIsoUrl
$dest = "C:\Install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
Invoke-WebRequest $source -OutFile $dest

$source = $SqlConfigurationUrl
$dest = "C:\Install\ConfigurationFile.ini"
Invoke-WebRequest $source -OutFile $dest

$sqladmin = Get-Content 'c:\sqluser.txt'
(Get-Content c:\install\configurationfile.ini).replace("[ACCOUNT]", $sqladmin  ) | Set-Content C:\Install\MyConfigurationFile.ini 

$TempExtractDir = 'C:\Install\SQLInstall'
New-Item -ItemType Directory "$TempExtractDir" -Force
$7zip = "C:\Program Files\7-Zip"   
& $7zip\7z.exe x C:\install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso -oc:\install\sqlinstall
Set-Location $TempExtractDir
Start-Process -FilePath c:\install\sqlinstall\setup.exe -ArgumentList '/ConfigurationFile="C:\Install\MyConfigurationFile.ini"' -Wait -NoNewWindow

# BizTalk
# download
Invoke-WebRequest -Uri $BizTalkUrl -OutFile C:\install\BTS2016Evaluation_EN.iso

$TempExtractDir = 'C:\Install\BizTalkInstall'
New-Item -ItemType Directory "$TempExtractDir" -Force

$7zip = "C:\Program Files\7-Zip"   
& $7zip\7z.exe x C:\install\BTS2016Evaluation_EN.iso -oc:\install\biztalkinstall
Set-Location $TempExtractDir

$argslist = @"
/quiet /addlocal all /COMPANYNAME 'BizTalkLab' /USERNAME 'BizTalkUser' /L c:\install\BizTalkInstallLog.txt
"@
Start-Process -FilePath "$biztalkpath\setup.exe" -argumentlist $argslist -wait -NoNewWindow