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
extern ofstream logout;
ofstream errorout;
ofstream parseout;
extern SymbolTable table;


void yyerror(char *s)
{
	//write your code
    printf("In yyerror:");
}
%}


%union  {
            SymbolInfo* symbolInfo;
        }


%token<symbolInfo> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token<symbolInfo> ID
%token<symbolInfo> CONST_INT CONST_FLOAT
%token<symbolInfo> ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON PRINTLN



%left 
%right

%nonassoc 


%%
input:              /* empty string */
    | input line
    ;
line: NEWLINE
    | expr NEWLINE           { printf("\t%.10g\n",$1); }
    ;
expr: expr PLUS term         { $$ = $1 + $3; }
    | expr MINUS term        { $$ = $1 - $3; }
    | term
    ;
term: term ASTERISK factor   { $$ = $1 * $3; }
    | term SLASH factor      { $$ = $1 / $3; }
    | factor
    ;
factor: LPAREN expr RPAREN  { $$ = $2; }
      | NUMBER
      ;
%%

main()
{
    yyparse();
    exit(0);
}
