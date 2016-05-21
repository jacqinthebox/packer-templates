#Templates for Packer (Virtualbox and Parallels support)

##Introduction
This repository contains Windows templates that can be used to create boxes for Vagrant using Packer.
It borrows from [https://github.com/joefitzgerald/packer-windows](https://github.com/joefitzgerald/packer-windows) and is inspired by [https://github.com/mwrock/packer-templates](https://github.com/mwrock/packer-templates).

##Packer Version
The Windows boxes are created with Packer version 0.10.0 and are using WinRM (no SSH).

##Prerequisites
[Vagrant](https://www.vagrantup.com), [Packer](https://www.packer.io) and Virtualbox or Parallels.

###Linux 
Install them with your package provider.

###MacOS
You will need [Parallels Desktop 11](https://www.parallels.com/eu/products/desktop/download/). 
Install with Brew:
```bash
brew cask install vagrant
brew cask install packer
vagrant plugin install vagrant-parallels
```
You also need the [Parallels Virtualization SDK](http://www.parallels.com/download/pvsdk/).

###Windows (10)
You can install the prerequisites with packagemanagement:
```Powershell
Install-Package -ProviderName Chocolatey - ForceBootstrap -Force vagrant,virtualbox,packer
```

##Howto

Build for Virtualbox
```
packer build -only virtualbox-iso windows_server_2016.json
```

Or for Parallels:
```
packer build -only parallels-iso windows_server_2016.json
```

Add the box to Vagrant:
```
vagrant box add --name windows_server_2016 windows2016_parallels.box 
```

###Trial version keys
In case you need them:
* Standard Key: MFY9F-XBN2F-TYFMP-CCV49-RMYVH
* Datacenter Key: 6XBNX-4JQGW-QX6QG-74P76-72V67
