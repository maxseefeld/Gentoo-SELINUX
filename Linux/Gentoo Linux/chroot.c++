//maxwell seefeld 
//1/27/2021
//gentoo chroot
 
#include<iostream> 
#include<string> 
#include<stdlib.h>

using namespace std;

int main()
{
	//takes in users partition
	string partition;

	//system functions run directly to terminal
	system("mkdir /mnt/mychroot");
	cout << "Enter the partition you want to mount: \n";
 	
   	system("mount /dev/nvme0n1p3 /mnt/mychroot");
 	system("mount --rbind /dev /mnt/mychroot/dev");
 	system("mount --make-rslave /mnt/mychroot/dev ");
	system("mount -t proc /proc /mnt/mychroot/proc");
	system("mount --rbind /sys /mnt/mychroot/sys");
	system("mount --rbind /tmp /mnt/mychroot/tmp ");
	system("cp /etc/resolv.conf /mnt/mychroot/etc");
	system("chroot /mnt/mychroot /bin/bash");
	system("env-update && . /etc/profile");
    return 0;
}

