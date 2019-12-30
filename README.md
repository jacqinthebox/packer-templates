# Windows templates for Packer 

## Introduction
This repository contains Windows templates that can be used to create boxes for Vagrant using Packer.
It is inspired by [https://github.com/mwrock/packer-templates](https://github.com/mwrock/packer-templates) and by [https://github.com/MattHodge/PackerTemplates](https://github.com/MattHodge/PackerTemplates).
I was a bit stuck until I read [https://hodgkins.io/best-practices-with-packer-and-windows](https://hodgkins.io/best-practices-with-packer-and-windows). My previous approach of stuffing all box creating effort in 1 file was very cumbersome. Turns out you can use a modular approach with Packer by creating multiple artifacts and chain them together.

## How to

### Prerequisites
The Windows boxes are created with Packer version 1.5.1 and are using WinRM.
[Vagrant](https://www.vagrantup.com), [Packer](https://www.packer.io) and Virtualbox.

**Linux:**
Install them with your package provider or manually, for example like so:

```bash
wget https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_linux_amd64.zip
unzip vagrant_2.2.6_linux_amd64.zip
sudo mv vagrant /usr/local/bin

wget https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip
unzip packer_1.5.1_linux_amd64.zip
sudo mv packer /usr/local/bin
```

**Windows VirtualBox:**

You can install the prerequisites with packagemanagement:
```Powershell
Install-Package -ProviderName Chocolatey -ForceBootstrap -Force vagrant,virtualbox,packer
```


### Clone and run

Clone the repository:
```
git clone https://github.com/jacqinthebox/packer-templates.git; cd packer-templates
```

### Create a box

Create a Windows 10 box:   

```bash
packer build --force virtualbox_windows_10_1_base.json
packer build --force virtualbox_windows_10_2_updates.json
packer build --force virtualbox_windows_10_3_package.json
```

Create a Windows Server 2019 box:   

```bash
packer build --force virtualbox_windows_server_2019_1_base.json
packer build --force virtualbox_windows_server_2019_2_updates.json
packer build --force virtualbox_windows_server_2019_3_package.json
```

### Add the box to Vagrant

```bash
vagrant box add --name windows_10 windows10_vbox.box
```


## Or just use the boxes from the Vagrant cloud

Create a Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "lab01" do |lab01_config|
    lab01_config.vm.box = "jacqinthebox/windows10"
    lab01_config.vm.hostname ="lab01"
    
    lab01_config.vm.provider "virtualbox" do |v|
      v.linked_clone = true
    end
  end
end
```
And do

```sh
vagrant up
```

This may take a while because the boxes are around 6 Gigabytes.

[https://app.vagrantup.com/boxes/search?order=desc&page=1&provider=&q=jacqinthebox](https://app.vagrantup.com/boxes/search?order=desc&page=1&provider=&q=jacqinthebox)