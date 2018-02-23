
Configuration BizTalkConfig {
   
    Import-DscResource -ModuleName PSDesiredStateConfiguration, cChoco
        
    $SqlIsoUrl = "https://s3-eu-west-1.amazonaws.com/freeze/SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
    $SqlConfigurationUrl = "https://s3-eu-west-1.amazonaws.com/freeze/ConfigurationFile.ini"
    $BizTalkUrl = "http://care.dlservice.microsoft.com/dl/download/6/B/C/6BCBE623-03A5-42AC-95AC-2873B68D10B9/BTS2016Evaluation_EN.iso"
    $OdtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_8529.3600.exe"
        
    $SqlUser = "Vagrant"
    $ParametersPath = "C:\Parameters"
    New-Item -ItemType directory -Path $ParametersPath -Force
        
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
    Set-Content -path "c:\parameters\excel.xml" -Value $excel  
        
        
            
    $SqlUser = "$env:computername\$SqlUser"
    Set-Content -path "$ParametersPath\sqluser.txt" -Value $SqlUser
    Set-Content -path "$ParametersPath\nodename.txt" -Value $env:computername
    Set-Content -path "$ParametersPath\odturl.txt" -Value $OdtUrl
            
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
        
            
    Node localhost
    {
      LocalConfigurationManager
      {
        RebootNodeIfNeeded = $False
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
        
      Script PrepareSQLConfiguration {     
        GetScript = {
          return @{ 'Result' = "PrepareSQLConfiguration" }
        }
         
        TestScript = {
          $Result = Test-Path "C:\Install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
          return $Result
        }
         
        SetScript = {
          Invoke-WebRequest -Uri $using:SqlIsoUrl -OutFile C:\install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso
          Invoke-WebRequest -Uri $using:SqlConfigurationUrl -OutFile C:\install\configurationfile.ini
          $sqluser = get-content c:\parameters\sqluser.txt
          (Get-Content c:\install\configurationfile.ini).replace("[ACCOUNT]", $sqluser  ) | Set-Content c:\install\myconfigurationFile.ini 
        }
      }
        
            
      Script ExpandSQLIso {
        GetScript ={
          return @{ 'Result' = "ExpandSQLIso" }
        }
        SetScript = {
          $TempExtractDir = 'c:\Install\SQLInstall'
          New-Item -ItemType Directory "$TempExtractDir" -Force
          $7zip = "C:\Program Files\7-Zip"   
          & $7zip\7z.exe x c:\install\SQLServer2016SP1-FullSlipstream-x64-ENU.iso -oc:\install\sqlinstall
          Set-Location $TempExtractDir
                   
        } 
        TestScript = {
          Test-Path "c:\install\sqlinstall\setup.exe"
        }
        
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
          cd c:\install\SQLInstall
          .\Setup.exe /ConfigurationFile="c:\Install\MyConfigurationFile.ini"
    }
        DependsOn = "[Script]ExpandSQLIso"
      }
        
                
                 
      Script InstallOffice2016 {     
        GetScript = {
          return @{ 'OdtUrl' = "$OdtUrl" }
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
          copy-item C:\Parameters\excel.xml -Destination c:\install
          $arglist1 = '/download excel.xml'
          $arglist2 = '/configure excel.xml'
          Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist1 -Wait -NoNewWindow
          Start-Process -FilePath c:\install\setup.exe -ArgumentList $arglist2 -Wait -NoNewWindow
        }
      }
           
                
                
      Script DownloadAndExtractBizTalk {
        
        GetScript = {
          return @{ 'Result' = "Extract BizTalk" }
                  
        }
        TestScript = {
          $Result = Test-Path "C:\Install\BizTalkInstall\BizTalk Server\Setup.exe"
          return $Result
        }
        
        SetScript = {
          Invoke-WebRequest -Uri $using:BizTalkUrl -OutFile C:\install\BTS2016Evaluation_EN.iso
          $TempExtractDir = 'C:\Install\BizTalkInstall'
          New-Item -ItemType Directory "$TempExtractDir" -Force
          $7zip = "C:\Program Files\7-Zip"   
          & $7zip\7z.exe x C:\install\BTS2016Evaluation_EN.iso -oc:\install\biztalkinstall
          Set-Location $TempExtractDir
        }
        
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
          $biztalkpath = 'C:\Install\BizTalkInstall\BizTalk Server' 
              
          set-location $biztalkpath
          $argslist = @"
        /quiet /addlocal all /COMPANYNAME 'BizTalkLab' /USERNAME 'BizTalkUser' /L c:\install\BizTalkInstallLog.txt
  "@
          Start-Process -FilePath "C:\Install\BizTalkInstall\BizTalk Server\Setup.exe" -argumentlist $argslist -wait -NoNewWindow
        }
        DependsOn = "[Script]DownloadAndExtractBizTalk" 
      }
               
    }
  }