#!bin/bash
mkdir /mnt/mychroot 
mount /dev/nvme0n1p3 /mnt/mychroot
mount --rbind /dev /mnt/mychroot/dev 
mount --make-rslave /mnt/mychroot/dev 
mount -t proc /proc /mnt/mychroot/proc
mount --rbind /sys /mnt/mychroot/sys
mount --make-rslave /mnt/mychroot/sys
mount --rbind /tmp /mnt/mychroot/tmp 
cp /etc/resolv.conf /mnt/mychroot/etc
chroot /mnt/mychroot /bin/bash
env-update && . /etc/profile
export PS1="(chroot) $PS1"
