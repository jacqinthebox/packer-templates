#!/bin/bash
#Install Ubuntu 17.10 Desktop

##Init
green=`tput setaf 2`
echo "${green} updating system and installing essential software"  

# install essentials
sudo apt-get install -y wget curl git gitk vim-nox chromium-browser build-essential linux-headers-$(uname -r) gparted nautilus-dropbox gdebi shutter gnome-tweak-tool
sudo apt-get install keepass2 -y

# install .net core
sudo apt-get install -y dotnet-sdk-2.0.2 

mkdir ~/gitrepos
cd gitrepos
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
echo "${green} Change the font in the terminal profile!"

echo "${green} Node.js and npm fix"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir ~/npm-global -p
echo "${green} setting permissions on new npm-global folder for $USER"
sudo chown -R $USER:$USER ~/npm-global
npm config set prefix '~/npm-global'

#Open or create a ~/.profile file and add this line:
echo "export PATH=~/npm-global/bin:$PATH" >> ~/.profile
source ~/.profile

# install theme
sudo apt-get install -y arc-theme
sudo add-apt-repository ppa:noobslab/icons
sudo add-apt-repository ppa:numix/ppa -y
sudo apt-get update
sudo apt-get install numix-icon-theme-circle -y
sudo apt-get install -y ultra-flat-icons ultra-flat-icons-green ultra-flat-icons-orange

echo "${green} installing and configuring zsh and oh-my-zsh"
sudo apt-get install zsh git-core -y
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd ..
rm -rf fonts

sed -i -e 's/agnoster/robbyrussel/g' ~/.zshrc
echo "DEFAULT_USER="\""$USER"\""" >> ~/.zshrc

echo "${green} Node.js and npm fix"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir ~/npm-global -p
echo "${green} setting permissions on new npm-global folder for $USER"
sudo chown -R $USER:$USER ~/npm-global
npm config set prefix '~/npm-global'
#Open or create a ~/.profile file and add this line:
echo "export PATH=~/npm-global/bin:$PATH" >> ~/.profile
source ~/.profile


echo "${green} configuring vim and enabling pathogen"
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdtree.git
git clone https://github.com/Valloric/MatchTagAlways.git
git clone https://github.com/ctrlpvim/ctrlp.vim.git
git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
git clone https://github.com/lukaszb/vim-web-indent.git
git clone https://github.com/hashivim/vim-vagrant.git
git clone https://github.com/altercation/vim-colors-solarized.git
cd ~
git clone https://github.com/flazz/vim-colorschemes.git
cd vim-colorschemes
mv colors ~/.vim/colors
rm ~/vim-colorschemes -rf

echo "${green} copying the vimrc"
wget -O .vimrc http://files.in-the-box.nl/vimrc.txt


echo "${green} git user config:"
git config --global user.name $USER
git config --global user.email $USER@$HOSTNAME.nl

mkdir ~/code

cd ~/Downloads

echo "${green} to add key to Github:"
echo "${green} ssh-keygen -t rsa" 
echo "${green} xclip -sel clip < ~/.ssh/id_rsa.pub"








