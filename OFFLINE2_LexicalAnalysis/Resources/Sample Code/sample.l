%option noyywrap

%{

#include<stdio.h>

int wordCount = 0;
int lineCount = 0;
void wc()
{

} 

%}

Letter [a-zA-Z]


%%

[ \t\v]+ {}
{Letter}+ {wordCount++ ;
    printf("%s found\n", yytext);
    }

[\n] {lineCount++;}
<<EOF>> {
    printf("Total Line Number : %d and word number : %d\n" , lineCount , wordCount );
    return 0;
}


%%

int main(int argc , char *argv[])
{
    if(argc != 2)
    {
        printf("Please provide input file name and try again");
        return 0;
    }

    FILE *fin = fopen(argv[1] , "r");

    if(fin == NULL)
    {
        printf("Can not specified file \n");
        return 0;
    }

    yyin = fin;
    yylex();
    fclose(yyin);
    return 0;
}