//maxwell seefeld 
//1/27/2021
//gentoo update script

#include<stdlib.h>
int main()
{

	system("emerge --sync");
    	system("emerge -avuDN --with-bdeps y --keep-going world");
    	system("etc-update");
    	system("lafilefixer --justfixit | grep -v skipping ");
    	system("emerge -av --depclean");
    	system("revdep-rebuild ");
    	system("eclean -d distfiles");
	return 0;
}
