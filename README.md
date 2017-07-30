# Templates for Packer (Virtualbox, Parallels and Hyper-V support)


## Introduction
This repository contains Windows templates that can be used to create boxes for Vagrant using Packer.
It is inspired by [https://github.com/mwrock/packer-templates](https://github.com/mwrock/packer-templates) and by [https://github.com/MattHodge/PackerTemplates](https://github.com/MattHodge/PackerTemplates).
I was a bit stuck until I read [https://hodgkins.io/best-practices-with-packer-and-windows](https://hodgkins.io/best-practices-with-packer-and-windows). My previous approach of stuffing all box creating effort in 1 file was very cumbersome. Turns out you can use a modular approach with Packer by creating multiple artifacts and chain them together.

## New! Hyper-V support in packer
Now you can create Hyper-V boxes on Windows with Hyper-V enabled. Unfortunately the modular approach does not work with Hyper-V. 


## How to
### Prerequisites
The Windows boxes are created with Packer version 0.12.2 and are using WinRM (no SSH).
[Vagrant](https://www.vagrantup.com), [Packer](https://www.packer.io) and Virtualbox or Parallels.

**Linux:**
Install them with your package provider.

**MacOS:**
* You will need [Parallels Desktop 12](https://www.parallels.com/eu/products/desktop/download/). Unfortunately you need the Pro Edition for Vagrant support!
* Install with Brew:
```bash
brew cask install vagrant
vagrant plugin install vagrant-parallels
```
* You also need the [Parallels Virtualization SDK](http://www.parallels.com/download/pvsdk/).

**Windows VirtualBox:**
You can install the prerequisites with packagemanagement:
```Powershell
Install-Package -ProviderName Chocolatey -ForceBootstrap -Force vagrant,virtualbox,packer
```

**Windows Hyper-V (New!):**
You can install the prerequisites with packagemanagement. 
And you need to install Hyper-V:

```Powershell
Install-Package -ProviderName Chocolatey -ForceBootstrap -Force vagrant,packer
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
```


### Clone and run
Clone the repository:
```
git clone https://github.com/jacqinthebox/packer-templates.git; cd packer-templates
```
Save the [Packer](https://www.packer.io) executable in this folder.

How to create a Parallels Windows 2016 box:
```bash
./example_build_parallels_windows_2016.sh
```

How to create a Windows 2016 box for VirtualBox. 

```bash
./example_build_vbox_windows_2016.sh
```

How to create a Hyper-V box on Windows

```Powershell
.\packer.exe build --force .\templates\hyperv_windows_server_2016_1_base.json
```


## Adding the box to Vagrant

```
vagrant box add --name windows_server_2016 windows2016_parallels.box
```
