//maxwell seefeld
//3/10/2021
//oversimplification of a webscraper

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main(){
    char comand[105]="wget ", temp[100];
    printf("Enter the downloadable url ");
    scanf("%s", &temp);
    strcat(comand, temp);
    system(comand);
    
    
    return 0;
}
