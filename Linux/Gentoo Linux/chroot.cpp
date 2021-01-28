//maxwell seefeld
//1/27/2021
//gentoo chroot
 
#include<iostream>
#include<string>
#include<stdlib.h>

using namespace std;

int main()
{
    	//creating strings and entering values
	string partition;
	cout << "Enter the partition you want to mount: \n";
	cin >> partition;
	//this string only exists because c++ was being a cunt
 	string partition_locatition=("mount /dev/" + partition).c_str();

 	//running systems calls and returning nothing
	system( "mkdir /mnt/mychroot");
 	system((partition_locatition +" /mnt/mychroot").c_str());
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
