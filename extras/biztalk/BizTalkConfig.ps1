Configuration BizTalkConfig {
    Param ( 
        [string]$NodeName, 
        [String]$UserName,
        [string]$ProductVersion
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, cChoco

    $OdtUrl = "https://github.com/jacqinthebox/BizTalkAzureVM/raw/master/officedeploymenttool_8311.3600.exe"
    $ExcelConfigurationUrl = "https://raw.githubusercontent.com/jacqinthebox/BizTalkAzureVM/master/excel.xml"
    $SqlIsoUrl = "https://s3-eu-west-1.amazonaws.com/freeze/SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
    $SqlConfigurationUrl = "https://raw.githubusercontent.com/jacqinthebox/biztalkinstall/master/ConfigurationFile.ini"
    $BizTalkUrl = http://care.dlservice.microsoft.com/dl/download/6/B/C/6BCBE623-03A5-42AC-95AC-2873B68D10B9/BTS2016Evaluation_EN.iso
    $BizTalkCabUrl = "http://go.microsoft.com/fwlink/p/?LinkId=746413"
 
    $ParametersPath = "C:\Parameters"
    New-Item -ItemType directory -Path $ParametersPath -Force
    $SqlUser = "$NodeName\$username"
    Set-Content -path "$ParametersPath\sqluser.txt" -Value $SqlUser
    Set-Content -path "$ParametersPath\nodename.txt" -Value $NodeName
    Set-Content -path "$ParametersPath\productversion.txt" -Value $ProductVersion
	
    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $True
        }
	 
        File InstallDir {
            DestinationPath = "c:\install"
            Ensure = "present"
            Type = "Directory"
        } 
	  
        cChocoInstaller installChoco
        {
            InstallDir = "c:\choco"
        }
   
        cChocoPackageInstaller notepadplusplus
        {
            Name        = "notepadplusplus"
            DependsOn   = "[cChocoInstaller]installChoco"
        }

	 
        cChocoPackageInstaller installSumatra
        {
            Name = "sumatrapdf.install"
            DependsOn = "[cChocoInstaller]installChoco"
        }
	
        cChocoPackageInstaller installSSMS
        {
            Name = "install sql-server-management-studio"
            Ensure = "present"
            Version = "13.0.15000.23"
        }
        cChocoPackageInstaller installVisualStudio
        {
            Name = "install visualstudio2015community"
            Ensure = "present"
        }

        Script DownloadSQLIso
        {
            TestScript = {
                Test-Path "C:\Install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
            }
      
            GetScript = { 
                return @{ 'SqlIsoUrl' = "$SqlIsoUrl"}
            }

            SetScript = {
                $source = $using:SqlIsoUrl
                $dest = "C:\Install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
                Invoke-WebRequest $source -OutFile $dest
            }
        }

        Script DownloadSQLConfiguration
        {
            TestScript = {
                Test-Path "C:\Install\ConfigurationFile.ini"
            }
     
            GetScript = { 
                return @{ 'SqlConfigurationUrl' = "$SqlConfigurationUrl"}
            }

            SetScript = {
                $source = $using:SqlConfigurationUrl
                $dest = "C:\Install\ConfigurationFile.ini"
                Invoke-WebRequest $source -OutFile $dest
            }
        }


        Script DownloadBizTalkCab
        {
      
            GetScript = { 
                @{'BizTalkCabUrl' = "$BizTalkCabUrl"}
            }
      
            TestScript = {
                Test-Path "C:\Install\BtsRedistW2K12R2EN64.CAB"
            }
		   
            SetScript = {
                $source = $using:BizTalkCabUrl
                $dest = "C:\Install\BtsRedistW2K12R2EN64.CAB"
                Invoke-WebRequest $source -OutFile $dest
            }
        }

        cChocoPackageInstaller installSoapui
        {
            Name = "soapui"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        cChocoPackageInstaller install7zipcommandline
        {
            Ensure = 'Present'
            Name = "7zip.commandline"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        cChocoPackageInstaller install7zipinstall
        {
            Name = "7zip.install"
            DependsOn = "[cChocoInstaller]installChoco"
        }
   
        Log ExcelinstallLog
        {
            Message = "Starting to install Excel."
        }

        Script DownloadExcelConfiguration
        {
            TestScript = {
                Test-Path "C:\Install\excel.xml"
            }
     
            GetScript = { 
                return @{ 'ExcelConfigurationUrl' = "$ExcelConfigurationUrl"}
            }

            SetScript = {
                $source = $using:ExcelConfiguration
                $dest = "C:\Install\excel.xml"
                Invoke-WebRequest $source -OutFile $dest
            }
        }

        Script InstallOffice2016 {     
            GetScript = {
                return @{ 'OdtUrl' = " $OdtUrl" }
            }
 
            TestScript = {
                $Result = Test-Path "C:\Program Files (x86)\Microsoft Office\root\Office16\Excel.exe"
                return $Result
            }
 
            SetScript = {
                New-Item -ItemType Directory c:\Install\odt -force
		 
	
                Invoke-WebRequest -Uri $using:OdtUrl -OutFile C:\install\officedeploymenttool.exe
                Set-Location \install
                .\officedeploymenttool.exe /quiet /extract:c:\install
                $arglist1 = '/download excel.xml'
                $arglist2 = '/configure excel.xml'
                Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist1 -Wait -NoNewWindow
                Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist2 -Wait -NoNewWindow
            }
            DependsOn = "[Script]DownloadExcelConfiguration" 
        }
   
        Log SQLinstallLog
        {
            Message = "Finsihed Excel. Now starting to install SQL Server"
        }

        Script PrepareSQLConfiguration {     
            GetScript = {
                return @{ 'Result' = "PrepareSQLConfiguration" }
            }
 
            TestScript = {
                $Result = Test-Path "C:\Install\MyConfigurationFile.ini"
                return $Result
            }
 
            SetScript = {
                $sqladmin = Get-Content 'c:\sqluser.txt'
                (Get-Content c:\install\configurationfile.ini).replace("[ACCOUNT]", $sqladmin  ) | Set-Content C:\Install\MyConfigurationFile.ini 
      
            }
        }

        Script ExpandSQLIso {
            GetScript = {
    
                return @{ 'Result' = "ExpandSQLIso" }
            }
            SetScript = {
                $TempExtractDir = 'C:\Install\SQLInstall'
                New-Item -ItemType Directory "$TempExtractDir" -Force
                $7zip = "C:\Program Files\7-Zip"   
                & $7zip\7z.exe x C:\install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso -oc:\install\sqlinstall
                Set-Location $TempExtractDir
           
            } 
            TestScript = {
    
                Test-Path "c:\install\sqlinstall\setup.exe"
            }
            DependsOn = "[script]PrepareSQLConfiguration"
        }

        Script InstallSQLServer2016 {     
            GetScript = {
                return @{ 'Result' = "InstallSQLServer2016" }
            }
 
            TestScript = {
                $Result = Test-Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Binn"
                return $Result
            }
 
            SetScript = {
           
                Start-Process -FilePath c:\install\sqlinstall\setup.exe -ArgumentList '/ConfigurationFile="C:\Install\MyConfigurationFile.ini"' -Wait -NoNewWindow
 
            }
            DependsOn = "[Script]ExpandSQLIso"
        }
  
        Log StartBizTalkInstallLog
        {
            Message = "Installing BizTalk 2016. Check log in c:\install\BizTalkInstalllog.txt"
        } 

        Script InstallBizTalk {     
            GetScript = {
                return @{ 'Result' = "InstallBizTalk" }
            }
 
            TestScript = {
                Write-Verbose 'Testing Install of BizTalk Server 2016'
                $Result = Test-Path "C:\Program Files (x86)\Microsoft BizTalk Server 2016\Configuration.exe"
                If ($Result) { Write-Verbose "BizTalk already installed." } else { Write-Verbose "Not in desired state. Installing BizTalk." }
                Return $Result
            }
 
            SetScript = {
                Write-Verbose 'Installing BizTalk Server 2016'
                #some ugly code ensues here. 
                $biztalkpath = 'C:\BizTalk Server 2016 Developer\BizTalk Server' 
      
                set-location $biztalkpath
                $argslist = @"
/quiet /CABPATH "C:\Install\BtsRedistW2K12R2EN64.CAB" /addlocal all /COMPANYNAME 'BizTalkLab' /USERNAME 'BizTalkUser' /L c:\install\BizTalkInstallLog.txt
"@
                Start-Process -FilePath "$biztalkpath\setup.exe" -argumentlist $argslist -wait -NoNewWindow
            } 
        }
        Log AllDoneLog
        {
            Message = "All Done"
        } 
    }
}