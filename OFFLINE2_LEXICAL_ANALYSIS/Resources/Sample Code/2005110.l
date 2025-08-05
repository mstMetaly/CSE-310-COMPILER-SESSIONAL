%option noyywrap

%{
    #include<stdio.h>
    #include<stdlib.h>

    int lineCount = 1;

    FILE *logout;
    FILE *tokenout;

    %}



NEWLINE \n
DIGIT [0-9]





%%





{NEWLINE} {lineCount++ ;}



"if"        {
                fprint(tokenout , "<IF, %s>" , yytext);
                fprint(logout , "Line# %d: Token <IF> Lexeme <%s> found " , lineCount , yytext);
            }



"else"      {
                fprint(tokenout , "<else, %s>" , yytext);
                fprint(logout , "Line# %d: Token <ELSE> Lexeme <%s> found " , lineCount , yytext);
            }



"for"       {
                fprint(tokenout , "<FOR, %s>" , yytext);
                fprint(logout , "Line# %d: Token <FOR> Lexeme <%s> found " , lineCount , yytext);
            }



"while"     {
                fprint(tokenout , "<WHILE, %s>" , yytext);
                fprint(logout , "Line# %d: Token <WHILE> Lexeme <%s> found " , lineCount , yytext);
            }



"do"        {
                fprint(tokenout , "<DO, %s>" , yytext);
                fprint(logout , "Line# %d: Token <DO> Lexeme <%s> found " , lineCount , yytext);
            }



"break"     {
                fprint(tokenout , "<BREAK, %s>" , yytext);
                fprint(logout , "Line# %d: Token <BREAK> Lexeme <%s> found " , lineCount , yytext);
            }



"int"       {
                fprint(tokenout , "<INT, %s>" , yytext);
                fprint(logout , "Line# %d: Token <INT> Lexeme <%s> found " , lineCount , yytext);
            }



"char"      {
                fprint(tokenout , "<CHAR, %s>" , yytext);
                fprint(logout , "Line# %d: Token <CHAR> Lexeme <%s> found " , lineCount , yytext);
            }



"float"     {
                fprint(tokenout , "<FLOAT, %s>" , yytext);
                fprint(logout , "Line# %d: Token <FLOAT> Lexeme <%s> found " , lineCount , yytext);
            }



"double"    {
                fprint(tokenout , "<DOUBLE, %s>" , yytext);
                fprint(logout , "Line# %d: Token <DOUBLE> Lexeme <%s> found " , lineCount , yytext);
            }



"void"      {
                fprint(tokenout , "<VOID, %s>" , yytext);
                fprint(logout , "Line# %d: Token <VOID> Lexeme <%s> found " , lineCount , yytext);
            }



"return"    {
                fprint(tokenout , "<RETURN, %s>" , yytext);
                fprint(logout , "Line# %d: Token <RETURN> Lexeme <%s> found " , lineCount , yytext);
            }



"switch"    {
                fprint(tokenout , "<SWITCH, %s>" , yytext);
                fprint(logout , "Line# %d: Token <SWITCH> Lexeme <%s> found " , lineCount , yytext);
            }



"case"      {
                fprint(tokenout , "<CASE, %s>" , yytext);
                fprint(logout , "Line# %d: Token <CASE> Lexeme <%s> found " , lineCount , yytext);
            }



"default"   {
                fprint(tokenout , "<DEFAULT, %s>" , yytext);
                fprint(logout , "Line# %d: Token <DEFAULT> Lexeme <%s> found " , lineCount , yytext);
            }



"continue"  {
                fprint(tokenout , "<CONTINUE, %s>" , yytext);
                fprint(logout , "Line# %d: Token <CONTINUE> Lexeme <%s> found " , lineCount , yytext);
            }



/*Constants*/

{DIGIT}+    {
                fprint(tokenout , "<CONST_INT, %s>", yytext);
                fprint(logout , "Line# %d: Token <CONST_INT> Lexeme <%s> found " , lineCount , yytext);
            }



{DIGIT}*'.'{DIGIT}+ |

{DIGIT}+'E'{DIGIT}*     {
                            fprint(tokenout , "<CONST_FLOAT, %s>", yytext);
                            fprint(logout , "Line# %d: Token <CONST_FLOAT> Lexeme <%s> found " , lineCount , yytext);
                        }







/* Operators and Punctuations*/


"+"     | 

"-"         {
                fprint(tokenout , "<ADDOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <ADDOP> Lexeme <%s> found " , lineCount , yytext);
            }





"*" |

"/" |

 "%"        {
                fprint(tokenout , "<MULOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <MULOP> Lexeme <%s> found " , lineCount , yytext);
            }




"++"    |

"--"        {
                fprint(tokenout , "<INCOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <INCOP> Lexeme <%s> found " , lineCount , yytext);
            }





"<"     |

"<="    |

">"     |

">="    | 

"=="    |

"!="        {
                fprint(tokenout , "<RELOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <RELOP> Lexeme <%s> found " , lineCount , yytext);
            }




"="         {
                 fprint(tokenout , "<ASSIGNOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <ASSIGNOP> Lexeme <%s> found " , lineCount , yytext);
            }




"&&"    |
"||"        {
                fprint(tokenout , "<LOGICOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <LOGICOP> Lexeme <%s> found " , lineCount , yytext);
            }



"&" |
"|" |
"^" |
"<<"|
">>"        {
                 fprint(tokenout , "<BITOP, %s>", yytext);
                fprint(logout , "Line# %d: Token <BITOP> Lexeme <%s> found " , lineCount , yytext);
            }


"!"        {
                fprint(tokenout , "<NOT, %s>", yytext);
                fprint(logout , "Line# %d: Token <NOT> Lexeme <%s> found " , lineCount , yytext);
            }


"("         {
                fprint(tokenout , "<LPAREN, %s>", yytext);
                fprint(logout , "Line# %d: Token <LPAREN> Lexeme <%s> found " , lineCount , yytext);
            }


")"         {
                fprint(tokenout , "<RPAREN, %s>", yytext);
                fprint(logout , "Line# %d: Token <RPAREN> Lexeme <%s> found " , lineCount , yytext);
            }


"{"         {
                fprint(tokenout , "<LCURL, %s>", yytext);
                fprint(logout , "Line# %d: Token <LCURL> Lexeme <%s> found " , lineCount , yytext);
            }


"}"         {
                fprint(tokenout , "<RCURL, %s>", yytext);
                fprint(logout , "Line# %d: Token <RCURL> Lexeme <%s> found " , lineCount , yytext);
            }

"["         {
                fprint(tokenout , "<LSQUARE, %s>", yytext);
                fprint(logout , "Line# %d: Token <LSQUARE> Lexeme <%s> found " , lineCount , yytext);
            }


"]"         {
                fprint(tokenout , "<RSQUARE, %s>", yytext);
                fprint(logout , "Line# %d: Token <RSQUARE> Lexeme <%s> found " , lineCount , yytext);
            }

","         {
                fprint(tokenout , "<COMMA, %s>", yytext);
                fprint(logout , "Line# %d: Token <COMMA> Lexeme <%s> found " , lineCount , yytext);
            }


";"         {
                fprint(tokenout , "<SEMICOLON, %s>", yytext);
                fprint(logout , "Line# %d: Token <SEMICOLON> Lexeme <%s> found " , lineCount , yytext);
            }






/*Identifiers */




/*Strings*/





/*Comments*/





/* Whitespaces*/






/*Lexical error*/





/*Wrong indentation*/





%%





int main(int argc , char *argv[])
{
    if(argc != 2)
    {
        printf("Please provide input file name and try again\n");
        return 0;
    }

    FILE *fin = fopen(argv[1] , "r");

    if(fin == NULL)
    {
        printf("Cannot open specified file\n");
		return 0;
    }

    logout = fopen("log.txt"  , "w");
    tokenout = fopen("token.txt" , "w");

    yyin = fin;
    yylex();

    fclose(yyin);
    fclose(tokenout);
    fclose(logout);

    return 0;

}
