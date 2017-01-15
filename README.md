# Templates for Packer (Virtualbox, Parallels and Hyper-V support)

## TLDR

What you need to create a Windows Vagrant box with Packer:
* lots and lots of disk space
* patience

Clone the repository:
```
git clone https://github.com/jacqinthebox/packer-templates.git; cd packer-templates
```
Save the [Packer](https://www.packer.io) executable in this folder.

Create a Windows 2016 box for Parallels:
```bash
./example_build_parallels_box.sh
```

Create a Windows 2016 box for VirtualBox:
```bash
./example_build_vbox_box.sh
```

Create a Windows 2016 box for Hyper-V.
Add [this](https://bintray.com/dwickern/packer-plugins/packer-post-processor-virtualbox-to-hyperv/0.1.0#files) plugin to the packer-templates folder. Create and run this script:

```bash
#!/bin/bash
./packer build ./virtualbox_windows_server_2016_1_base.json
./packer build ./virtualbox_windows_server_2016_2_updates.json
./packer build ./virtualbox_windows_server_2016_3_package_only.json
./packer build ./virtualbox_windows_server_2016_4_hyperv_export.json
```

This should also work on Windows (change the bash for cmd or ps1 and you're good to go).


## Introduction
This repository contains Windows templates that can be used to create boxes for Vagrant using Packer.
It is inspired by [https://github.com/mwrock/packer-templates](https://github.com/mwrock/packer-templates) and by [https://github.com/MattHodge/PackerTemplates](https://github.com/MattHodge/PackerTemplates).
I was a bit stuck until I read [https://hodgkins.io/best-practices-with-packer-and-windows](https://hodgkins.io/best-practices-with-packer-and-windows). My previous approach of stuffing all box creating effort in 1 file was very cumbersome. Turns out you can use a modular approach with Packer by creating multiple artifacts and chain them together.

### Multi Step approach
1. Create a base image and save it to a pvm or ovf files
2. Load the pvm or ovf from step 1 and install Windows Updates
3. Load the pvm or ovf from step 2, install tools and do some other stuff, reboot, compress and generate the Vagrant box.  

Optional step for Virtualbox: Generate a Hyper-V box from the Virtualbox artifact from step 2.

## Packer Version
The Windows boxes are created with Packer version 0.12.0 and are using WinRM (no SSH).

##Prerequisites
[Vagrant](https://www.vagrantup.com), [Packer](https://www.packer.io) and Virtualbox or Parallels.

### Linux
Install them with your package provider.

### MacOS
* You will need [Parallels Desktop 12](https://www.parallels.com/eu/products/desktop/download/). Unfortunately you need the Pro Edition for Vagrant support!
* Install with Brew:
```bash
brew cask install vagrant
vagrant plugin install vagrant-parallels
```
* You also need the [Parallels Virtualization SDK](http://www.parallels.com/download/pvsdk/).

### Windows (10)
You can install the prerequisites with packagemanagement:
```Powershell
Install-Package -ProviderName Chocolatey -ForceBootstrap -Force vagrant,virtualbox,packer
```

## Adding the box to Vagrant

```
vagrant box add --name windows_server_2016 windows2016_parallels.box
```
