%option noyywrap



%{
#include<bits/stdc++.h>
#include<iostream>

#include "2005110.h"


using namespace std ;


int lineCount = 1;
int errCount = 0;
int warningCount = 0;
int start =0;
int indentationCount = 0;
int spaceCount = 0;

string inputChar = "";
string inputString = "";
bool multiLineString =  false;
string token = "";

ofstream logout;
ofstream tokenout;

SymbolTable symboltable(10);



void printToken(string token , string lexeme , int lineNum)
{
	tokenout << "<" << token <<", " << lexeme << ">" << endl ;
	logout << "Line# "<< lineNum <<": Token <" << token << "> Lexeme " << lexeme << " found" << endl; 
}



%}

%x ESCAPED_CHAR_STATE
%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_LINE_COMMENT_STATE


WHITESPACE [ \t\f\r\v]+
DIGIT [0-9]
EXPONENT [Ee][+-]?{DIGIT}+?
FRACTION \.{DIGIT}+
LETTER [a-zA-Z_]
ALPHANUMERIC [a-zA-Z_0-9]
NEWLINE \n


%%


{NEWLINE} {
			lineCount++;
		
			spaceCount = 0;
		  }


^[\t]*  {
			spaceCount = yyleng;
			
			if(spaceCount == 0)
			{
				logout << "Line# " <<lineCount << ": warning, " << indentationCount <<" of tabs needed but got 0 tabs." << endl;
				warningCount++;
				spaceCount = 0;
			}

			else if(spaceCount != indentationCount)
			{
				logout << "Line# " << lineCount << ": warning, " << indentationCount << " of tabs needed but got " << spaceCount << " tabs." << endl;
				warningCount++;
				spaceCount = 0;
			}

}

^[\t][\t]+?[ ] {
				logout << "Line# " << lineCount << ": Warning, tab requrired but got space." << endl;
				warningCount++;
				spaceCount = 0;
               }



{WHITESPACE} {

			}



"if"        {
				printToken("IF" , yytext , lineCount);
			}

"else"      {	
				printToken("ELSE" , yytext , lineCount);
			}

"for"       {	
				printToken("FOR" , yytext , lineCount);
			}

"while"     {	
				printToken("WHILE" , yytext , lineCount);
			}

"do"        {
				printToken("DO" , yytext , lineCount);
			}

"break"     {	
				printToken("BREAK" , yytext , lineCount);
			}

"int"       {	
				printToken("INT" , yytext , lineCount);
			}

"char"      {	
				printToken("CHAR" , yytext , lineCount);
			}

"float"     {
				printToken("FLOAT" , yytext , lineCount);
            }

"double"    {
				printToken("DOUBLE" , yytext , lineCount);
            }

"void"      {
				printToken("VOID" , yytext , lineCount);
            }

"return"    {
				printToken("RETURN" , yytext , lineCount);
            }

"switch"    {
				printToken("SWITCH" , yytext , lineCount);
            }

"case"      {
				printToken("CASE" , yytext , lineCount);
            }

"default"   {
				printToken("DEFAULT" , yytext , lineCount);
            }

"continue"  {
				printToken("CONTINUE" , yytext , lineCount);
            }




{LETTER}{ALPHANUMERIC}*			{
									printToken("ID" , yytext , lineCount);

									string symbol = yytext;

									if(symboltable.Insert( symbol , "ID" ))
									{
										symboltable.PrintAllScopeTable(logout);
									}
									else{
										logout << '\t'<< yytext<<" already exists in the current ScopeTable" << endl;	
									}
								}




{DIGIT}+    						{
										printToken("CONST_INT" , yytext , lineCount);
            						}


{DIGIT}+{FRACTION}?{EXPONENT}?  |

{FRACTION}({EXPONENT}?)?			{
										printToken("CONST_FLOAT" , yytext , lineCount);
                        			}


{DIGIT}{DIGIT}+?{FRACTION}{FRACTION}+{EXPONENT} {
													logout << "Error at line# " << lineCount << ": TOO_MANY_DECIMAL_POINTS " << yytext << endl;
													errCount++;
										  		}


{DIGIT}{DIGIT}+?({FRACTION}{FRACTION}+)?{EXPONENT}{FRACTION}	{
																	logout << "Error at line# " << lineCount << ": ILLFORMED_NUMBER " << yytext << endl;
																	errCount++;
																}


{DIGIT}{DIGIT}+{LETTER}{LETTER}+{DIGIT}+? 		{
											string input = yytext;
											logout << "Error at line# " << lineCount << ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << endl;
											errCount++;
										}






"+"		|
"-"         {
				printToken("ADDOP" , yytext , lineCount);
            }

"%"		|
"/"		|
"*"			{	
				printToken("MULOP" , yytext , lineCount);
            }

"++"    |
"--"        {
				printToken("INCOP" , yytext , lineCount);
            }

"+++"		{
	printToken("PPP" , yytext , lineCount);
}




"<"     |
"<="    |
">"     |
">="    | 
"=="    |
"!="        {	
				printToken("RELOP" , yytext , lineCount);
            }


"="         {
				printToken("ASSIGNOP" , yytext , lineCount);
            }


"&&"    |
"||"        {	
				printToken("LOGICOP" , yytext , lineCount);
            }


"&" 	|
"|" 	|
"^" 	|
"<<"	|
">>"        {
				printToken("BITOP" , yytext , lineCount);
            }


"!"         {	
				printToken("NOT" , yytext , lineCount);
        	}

"("         {
				printToken("LPAREN" , yytext , lineCount);
            }


")"         {
				printToken("RPAREN" , yytext , lineCount);
            }


"{"         {
				indentationCount++;
				symboltable.EnterScope();
				printToken("LCURL" , yytext , lineCount);
            }


"}"         {
				--indentationCount;
				symboltable.ExitScope();
				printToken("RCURL" , yytext , lineCount);
            }

"["         {
				printToken("LSQUARE" , yytext , lineCount);
            }


"]"         {
				printToken("RSQUARE" , yytext , lineCount);
            }

","         {
				printToken("COMMA" , yytext , lineCount);
			}


";"         {
				printToken("SEMICOLON" , yytext , lineCount);
            }





"\'" 			{
    				BEGIN(ESCAPED_CHAR_STATE);
				}			


<ESCAPED_CHAR_STATE>(["\\"]["\'"])	{
										inputChar += "\\'";
									}


<ESCAPED_CHAR_STATE>[\\\"]			{
										inputChar += "\\";
										inputChar += '\"';
									}


<ESCAPED_CHAR_STATE>([\\][\\])		{
										inputChar += "\\";
										inputChar += "\\";
									}


<ESCAPED_CHAR_STATE>(["\\"]["n"])	{
										inputChar += "\n";
									}


<ESCAPED_CHAR_STATE>(["\\"]["t"])	{
										inputChar += "\t";
									}


<ESCAPED_CHAR_STATE>(["\\"]["a"])	{
										inputChar += "\a";
									}


<ESCAPED_CHAR_STATE>(["\\"]["f"])	{
										inputChar += "\f";
									}							


<ESCAPED_CHAR_STATE>(["\\"]["r"])	{
										inputChar += "\r";
									}					


<ESCAPED_CHAR_STATE>(["\\"]["b"])	{
										inputChar += "\b";
									}


<ESCAPED_CHAR_STATE>(["\\"]["v"])	{
										inputChar += "\v";
									}


<ESCAPED_CHAR_STATE>(["\\"]["0"])	{
										inputChar += "\0";
									}

<ESCAPED_CHAR_STATE>"'"				{
										if(inputChar.size()==0)
										{
											logout << "Error at line# " << lineCount << ": EMPTY_CONST_CHAR ''" << endl;
											errCount++;
										}
										else if(inputChar.size()==1 || (inputChar.size()==2 &&  inputChar[0] == '\\'))
										{
											printToken("CONST_CHAR" , inputChar , lineCount);
										}
										else
										{	
											string outputChar = "'";
											outputChar += inputChar;
											outputChar += "'";

											logout << "Error at line# " << lineCount << ": MULTICHAR_CONST_CHAR " << outputChar << endl;
											errCount++;
										}
										
										inputChar = "";
										BEGIN(INITIAL);
										
									}

<ESCAPED_CHAR_STATE><<EOF>>			{
										string outputChar = "'";
										outputChar += inputChar;
										
										logout << "Error at line# " << lineCount << ": UNFINISHED_CONST_CHAR " << outputChar << endl;
										errCount++;

										inputChar = "";
										BEGIN(INITIAL);
									}


<ESCAPED_CHAR_STATE>{NEWLINE}		{
										string outputChar = "'";
										outputChar += inputChar;
										
										logout << "Error at line# " << lineCount << ": UNFINISHED_CONST_CHAR " << outputChar << endl;

										errCount++;

										inputChar = "";
										lineCount++;

										BEGIN(INITIAL);
									}

<ESCAPED_CHAR_STATE>.				{
										inputChar += yytext[0];
									}
	


\"							{
								BEGIN(STRING_STATE);
								start = lineCount;
							}

<STRING_STATE>\\\"			{
								inputString += "\\";
								inputString += "\"";
							}


<STRING_STATE>\\[\r]?[\n]	{
								inputString += "\\";
								inputString += '\n';
								multiLineString = true;
								lineCount++;
							}


<STRING_STATE>[\r]?\n	{	
							string outputString = "\"";
							outputString += inputString;

							logout << "Error at line# " << lineCount << ": UNFINISHED_STRING " << outputString << endl;

							errCount++;
							lineCount++;

							inputString = "";
							multiLineString = false;

							BEGIN(INITIAL);	
						}


<STRING_STATE>(["\\"]["t"])	{
								token += "\t";
								inputString += "\\";
								inputString += "t";
							}



<STRING_STATE>(["\\"]["a"])	{
								token += "\a";
								inputString += "\\";
								inputString += "a";
							}


<STRING_STATE>(["\\"]["f"])	{
								token += "\f";
								inputString += "\\";
								inputString += "f";
							}							


<STRING_STATE>(["\\"]["r"])	{
								token += "\r";
								inputString += "\\";
								inputString += "r";
							}					


<STRING_STATE>(["\\"]["b"])	{
								token += "\b";
								inputString += "\\";
								inputString += "b";
							}


<STRING_STATE>(["\\"]["v"])	{
								token += "\v";
								inputString += "\\";
								inputString += "v";
							}


<STRING_STATE>(["\\"]["0"])	{
								token += "\0";
								inputString += "\\";
								inputString += "0";
							}


<STRING_STATE>\"		{
							string outputString = "\"";
							outputString += inputString;
							outputString += "\"";

							if(!multiLineString)
							{
								tokenout << "<SINGLE LINE STRING, " << token << ">" << endl;
								logout <<  "Line# " << lineCount << ": Token <SINGLE LINE STRING> Lexeme " << outputString << " found" << endl;

							}
							else
							{	
								tokenout << "<MULTI LINE STRING, " << token << ">" << endl;
								logout <<  "Line# " << start << ": Token <MULTI LINE STRING> Lexeme " << outputString << " found" << endl;

							}

							inputString = "";
							token = "";
							multiLineString = false;
							BEGIN(INITIAL);
							
						}



<STRING_STATE><<EOF>>	{
							string outputString = "\"";
							outputString += inputString;

							logout << "Error at line# " << lineCount << ": UNFINISHED_STRING " << outputString << endl;

							errCount++;

							multiLineString = false;
							inputString = "";
							BEGIN(INITIAL);
						}



<STRING_STATE>.			{
							inputString += yytext;
							token += yytext;
						}




\/\/								{
										BEGIN(SINGLE_COMMENT_STATE);
										inputString += "//";
										start = lineCount ;
									}

<SINGLE_COMMENT_STATE>[\\][\r]?[\n]	{
										inputString += "\\";
										inputString += '\n';
										lineCount++;

										multiLineString = true;

									}


<SINGLE_COMMENT_STATE>[\r][\n]		{
										if(!multiLineString)
										{
											logout <<  "Line# " << start << ": Token <SINGLE LINE COMMENT> Lexeme " << inputString << " found" << endl;
										}
										else
										{	
											logout <<  "Line# " << start << ": Token <SINGLE LINE COMMENT> Lexeme " << inputString << " found" << endl;
										}
										lineCount++;
										inputString = "";
										multiLineString = false;

										BEGIN(INITIAL);
									}


<SINGLE_COMMENT_STATE>.				{
										inputString += yytext;
									}




\/\*								{
										BEGIN(MULTI_LINE_COMMENT_STATE);
										inputString += "/";
										inputString += "*";
										start = lineCount;
									}

<MULTI_LINE_COMMENT_STATE>\n		{
										inputString += "\n";
										lineCount++;
									}

<MULTI_LINE_COMMENT_STATE><<EOF>>	{
										logout << "Error at line# " << lineCount << ": UNFINISHED_COMMENT " << inputString << endl;

										errCount++;

										inputString = "";
										BEGIN(INITIAL);
									}


<MULTI_LINE_COMMENT_STATE>[\*][\/]	{
										
										inputString += "*";
										inputString += "/";

										logout <<  "Line# " << start << ": Token <MULTI LINE COMMENT> Lexeme " << inputString << " found" << endl;

										inputString = "";
										BEGIN(INITIAL);
									}


<MULTI_LINE_COMMENT_STATE>.			{
										inputString += yytext[0];
									}


.		{
			string input = yytext;
			logout << "Error at line# " << lineCount << ": UNRECOGNIZED_CHAR " << input << endl;

			errCount++;
		}




%%



int main(int argc,char *argv[]){

	/*flex -o 2005110.cpp 2005110.l
    g++ 2005110.cpp -o 2005110.out
    ./2005110.out input.txt*/
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin = fopen(argv[1],"r");

	if(fin == NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	logout.open("2005110_log.txt");
	tokenout.open("2005110_token.txt");

	yyin= fin;

	yylex();


	symboltable.PrintCurrentScopeTable(logout);
	
	logout <<  "Total lines: " << lineCount << endl;
	logout << "Total errors: "<< errCount << endl;
	logout << "Total warnings: " << warningCount << endl;

	fclose(yyin);
	
	return 0;
}
