%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "2005110.h" 
    
using namespace std;
    
int yyparse(void);
int yylex(void);

extern FILE* yyin;


    
%}


%%



%%

int main()
{
    if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File");
		exit(1);
	}

	logout.open("log.txt");
    errorout.open("error.txt");
    parseout.open("parse_tree.txt");
	

	yyin=fp;
	yyparse();
	
	
	return 0;
}