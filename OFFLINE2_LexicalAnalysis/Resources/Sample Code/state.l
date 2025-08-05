%option noyywrap


%{
#include<bits/stdc++.h>
#include<stdio.h>
#include<stdlib.h>

using namespace std;

string s = "";


%}


%x MYSTATE

%%

[ \t\n]+ {}
<MYSTATE>[ \t\n]+ {}

abc {
		BEGIN MYSTATE; 
		printf("MYSTATE started at %s\n",yytext);
	}

<MYSTATE>def 	{
					s +="metaly";
					printf("ending mystate at %s\n", s.c_str()); 
					BEGIN INITIAL;
				}

<MYSTATE>.  {}

[a-z]+ 	{
			printf("In initial State %s found\n",yytext);
		}

%%
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
