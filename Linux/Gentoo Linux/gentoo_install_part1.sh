#!bin/bash
#disk creation script 
#maxwell seefeld
#4/11/2021

sudo su
parted -a optimal /dev/nvme0n1
unit mib
mklabel gpt
mkpart primary 1 3 
name 1 grub 
set 1 bios_grub on
mkpart primary fat32 3 515
name 2 boot
set 2 BOOT on 
mkpart primary 515 -1
name 3 lvm
set 3 lvm on 
quit 
mkfs.vfat -F32 /dev/nvme0n1p2 
cryptsetup luksFormat /dev/nvme0n1p3 
cryptsetup luksOpen /dev/nvme0n1p3 lvm 
lvm pvcreate /dev/mapper/lvm 
vgcreate vg0 /dev/mapper/lvm 
lvcreate -L 25G -n root vg0 
lvcreate -L 40G -n var vg0
lvcreate -l 100%FREE -n home vg0 
mkfs.ext4 /dev/mapper/vg0-root 
mkfs.ext4 /dev/mapper/vg0-var 
mkfs.ext4 /dev/mapper/vg0-home

