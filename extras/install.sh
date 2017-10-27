# install essentials
sudo apt-get install -y wget curl git gitk vim-nox chromium-browser build-essential linux-headers-$(uname -r) dkms gparted nautilus-dropbox gdebi shutter unity-tweak-tool
sudo apt-get install keepass2 -y

# install .net core
mkdir -p $HOME/dotnet && tar zxf dotnet.tar.gz -C $HOME/dotnet
sudo apt-get install libunwind8
export PATH=$PATH:$HOME/dotnet 

# install theme
sudo apt-get install -y arc-theme
sudo apt-get install -y gnome-tweak-tool
sudo add-apt-repository ppa:noobslab/icons
sudo apt-get update
sudo apt-get install -y ultra-flat-icons ultra-flat-icons-green ultra-flat-icons-orange
