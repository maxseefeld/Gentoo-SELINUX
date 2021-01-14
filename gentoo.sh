#!/bin/bash
##Maxwell seefeld
##1/13/2021
##version 0.0 

echo "Welcome to the Gentoo install program."
echo "-----------------------------------------------"
echo ""
echo "CPU information acording to your system."
echo "-----------------------------------------------"
lscpu
echo
echo "Hard Drive information acording to your system."
echo "-----------------------------------------------"
lsblk
echo ""
echo "User input section."
echo "-----------------------------------------------"
read -p "Enter your cpu count. " count
read -p "Enter your user name. " user
read -p "Enter the desired password for the user. " password
read -p "Enter the desired password for root user. " root
read -p "Enter the desired password for the root partition. " rootpass
read -p "Enter the desired password for the home partition. " homepass
read -p "Enter the desired password for ram. " rampass
echo "Enter the name of hard drive. "
read -p "Enter the name of hard drive. 'if the name of your hard drive is nvme0n1 please change it to nvme0n1p.'" drive
read -p "Enter the hostname " host 
echo ""
echo "The entered cpu count is:" $count 
echo "The enter username is:" $user 
echo "The entered password for the user is:" $password
echo "The entered password for the root user is:" $root
echo "The entered password for the root partition is:" $rootpass
echo "The entered password for the home partiton is:" $homepass
echo "The entered password for the ram is:" $rampass
echo "The entered password for the hard drive is:" $drive
echo "The entered host name for the computer is:" $host

##Diffrent Partitions used for inputing minimal user data
one=1
two=2
three=3
four=4
five=5

##WRITING THE DISKS
fdisk -l
parted -a optimal /dev/"$drive$one"
rm (all)
mklabel gpt
unit mib
mkpart primary 1 512
name 1 boot
set 1 BOOT on
mkpart primary 512 -1
name 2 lvm
set 2 lvm on
p					-make boot,esp on 1e
quit 

mkfs.fat -F32 /dev/"$drive$one"

#LVM SHIT
modprobe dm-crypt
/etc/init.d/lvmetad restart
cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat /"$drive$two" --yes 
passphrase=$rootpass
cryptsetup luksDump /dev/"$drive$two"
cryptsetup luksOpen /dev/"$drive$two" $host
Enter passphrase
 
lvmdiskscan
 
pvcreate /dev/mapper/$host
pvdisplay
 
vgcreate gentoo /dev/mapper/$host
vgdisplay
 
lvcreate -C y -L 16G gentoo -n swap
lvcreate -L 32G gentoo -n root
lvcreate -L 65G gentoo -n var
lvcreate -l +100%FREE $host -n home
lvdisplay
 
vgscan (may say running but disabled)
 
vgchange -ay (should say active now)
 
mkswap /dev/mapper/gentoo-swap
mkfs.ext4 /dev/mapper/gentoo-root
mkfs.ext4 /dev/mapper/gentoo-var
mkfs.ext4 /dev/mapper/gentoo-home
 
swapon /dev/mapper/gentoo-swap
mount /dev/mapper/gentoo-root /mnt/gentoo
mkdir /mnt/gentoo/boot
mkdir /mnt/gentoo/home
mkdir /mnt/gentoo/var
mount /dev/$drive$one /mnt/gentoo/boot
mount /dev/mapper/gentoo-var /mnt/gentoo/var
mount /dev/mapper/gentoo-home /mnt/gentoo/home

lsblk 

 
free -m
 
### Install Base System ###
 
date
 
ntpd -q -g
 
cd /mnt/gentoo
links https://www.gentoo.org/downloads/mirrors/
	download Stage3 tarball
 
tar xpvf stage3-* --xattrs-include='*.*' --numeric-owner
 
nano -w /mnt/gentoo/etc/portage/make.conf
 
CFLAGS="-march=native..."
MAKE_OPTS="-j$count"
L10N="en-us"
ACCEPT_LICENSE="*"
 
#USE="ncurses plymouth cryptsetup crypt pulseaudio bluetooth python icu networkmanager branding png jpeg bindist"
 
#VIDEO_CARDS="intel nvidia"
#INPUT_DEVICES="libinput"
#ALSA_CARDS="hda-intel usb-audio"
 
 
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
 
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
		- may need to change "sync-rsync-verify-manifest = yes" to = no
 
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
 
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/dev
 
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm
 
mkdir /mnt/gentoo/hostrun
mount --bind /run /mnt/gentoo/hostrun/
 
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"
 
emerge-webrsync
 
emerge --sync		- change verify setting to "no" (above) if server error
 
# Set up /etc/portage
cd /etc/portage/
mkdir package.accept_keywords
 
# Install Vim (optional)
echo "app-editors/vim lua luajit perl python ruby terminal vim-pager" > package.use/vim
emerge -av vim eix
 
emerge -uvDNa @world
 
# Enable cpu features
emerge -av cpuid2cpuflags
 
cpuid2cpuflags >> /etc/portage/make.conf
 
echo "America/Los_Angeles" > /etc/timezone
emerge --config sys-libs/timezone-data
 
vim /etc/locale.gen
uncomment en_US-utf8
locale-gen
eselect locale list
eselect locale set X		-select en_US-utf8
 
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
 
eselect profile list
eselect profile set X		-likely no change - keep as base version until reboot
 
emerge -av gentoo-sources genkernel-next cryptsetup lvm2 linux-firmware
 

vim /etc/fstab
 
/dev/$drive$one					/boot	    vfat	noatime                     0 2
/dev/mapper/gentoo-root			/			ext4	rw,relatime,data=ordered    0 1
/dev/mapper/gentoo-home			/home		ext4	rw,relatime,data=ordered	0 2
/dev/mapper/gentoo-var			/var		ext4	rw,relatime,data=ordered	0 2
/dev/mapper/gentoo-swap			none		swap    defaults                    0 0
 
# Manual kernel config
cd /usr/src
ls -la
cd linux/
make menuconfig
    Google all system hardware (bluetooth, pulseaudio, thunderbolt, sd-card readers, etc)
make -j$count
make -j$count modules_install
make install
 
# Genkernel method
scp msjche@192.168.1.5:/home/msjche/Gentoo/kernel-config-4.19.97 /usr/src/linux
vim /etc/genkernel.conf
    enable LUKS, LVM
genkernel --makeopts=-j13 --menuconfig --lvm --luks --no-zfs all
    lvm requirements
    luks requirements (sha512,AES)
    nvme
 
    # if getting "not initialized in udev database" during boot (because / is in lvm)
    vim /etc/lvm/lvm.conf           - find and change the following:
 
        devices {
        multipath_component_detection = 0
        md_component_detection = 0
        }
 
    activation {
        udev_sync = 0
        udev_rules = 0
        }
 
genkernel --lvm --luks initramfs
 
echo "sys-boot/grub mount device-mapper" > /etc/portage/package.use/grub
emerge -av grub gentoolkit 
 
vim /etc/default/grub
 
GRUB_CMDLINE_LINUX="crypt_root=/dev/nvme0n1p2 root=/dev/mapper/gentoo-root rootfstype=ext4 dolvm quiet"
 
grub-install --target=x86_64-efi --efi-directory=/boot /dev/nvme0n1
 
grub-mkconfig -o /boot/grub/grub.cfg
 
passwd
 
useradd -m -G users,wheel,audio,video -s /bin/bash $user
passwd $password
 
rm stage...
 
echo "4n4rch14" > /etc/hostname
vim /etc/hosts
127.0.0.1    4n4rch1a.localdomain    localhost
 
emerge -av syslog-ng cronie mlocate
rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default
rc-update add lvm boot
 
# Networking
 
vim /etc/portage/make.conf
    uncomment USE="..."
 
desktop:
emerge -av net-misc/dhcpcd
 
laptop:
emerge -av wireless-tools net-tools app-text/tree wpa_supplicant networkmanager
emerge -av x11-misc/xdotool x11-misc/wmctrl         - for libinput
rc-update add NetworkManager default
 
tree /sys/class/net
 
zgrep 'IWLWIFI\|IWLDVM\|IWLMVM' /proc/config.gz
    * iwlwifi
    M iwldvm
    M iwlmvm
 
exit
cd
 
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
 
reboot
 
should see "Enter passphrase for /dev/sda2"
 
echo "SOLARIZED=TRUE" > /etc/eixrc/99-color
    SOLARIZED=true
 
## Updating Plymouth Theme
 
plymouth-set-default-theme --list
plymouth-set-default-theme set X
 
genkernel --luks --lvm initramfs
grub-mkconfig -o /boot/grub/grub.cfg


