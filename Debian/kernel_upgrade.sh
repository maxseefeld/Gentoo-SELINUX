#!/bin/bash 
echo "Run this scripts as sudo or else the changes will not take effect"
sudo apt-get update 
sudo apt-get upgrade 
sudo apt-get build-dep linux linux-image-$(uname -r)
sudo apt-get install libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
sudo apt-get install git
deb-src http://archive.ubuntu.com/ubuntu disco main
deb-src http://archive.ubuntu.com/ubuntu disco-updates main
apt-get source linux-image-unsigned-$(uname -r)
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-<release codename>.git
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-disco.git
chmod a+x debian/rules
chmod a+x debian/scripts/*
chmod a+x debian/scripts/misc/*
LANG=C fakeroot debian/rules clean
LANG=C fakeroot debian/rules editconfig
LANG=C fakeroot debian/rules clean
# quicker build:
LANG=C fakeroot debian/rules binary-headers binary-generic binary-perarch
# if you need linux-tools or lowlatency kernel, run instead:
LANG=C fakeroot debian/rules binary
cd ..
ls *.deb
linux-headers-4.8.0-17_4.8.0-17.19_all.deb
linux-headers-4.8.0-17-generic_4.8.0-17.19_amd64.deb
linux-image-4.8.0-17-generic_4.8.0-17.19_amd64.deb
sudo dpkg -i linux*4.8.0-17.19*.deb
sudo apt remove app-armor 
sudo apt-get install selinux
echo "after the install takes place you have to manually change the selinux status to enabled 
this script only ensures that the modules are installed and the kernel is upgraded"
sudo reboot
