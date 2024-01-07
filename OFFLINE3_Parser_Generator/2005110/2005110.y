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
extern int lineCount;
extern int errCount;
ofstream error_out;
ofstream parse_out;

extern SymbolTable table;


void yyerror(const char *s)
{
	//write your code
    //printf("In yyerror:");
}


void printParseTree(SymbolInfo* symbolInfo , int level)
{
	for(int i = 0; i < level ; i++)
	{
		parse_out << " ";
	}

	if(symbolInfo->getIsLeaf())
	{
		parse_out << symbolInfo->getType()<< " : " << symbolInfo->getName() << "	<Line: " << symbolInfo->getStartLine() << ">" << endl;
		return;
	}
	else{
		parse_out << symbolInfo->getParseTreeLine() << " 	" << "<Line: " << symbolInfo->getStartLine() << "-" << symbolInfo->getEndLine() << ">" << endl;
	}

	vector<SymbolInfo*>childList = symbolInfo->getChildList();

	for(int i = 0 ; i < childList.size() ; i++)
	{
		SymbolInfo* symbol = childList[i];
		printParseTree(symbol , level+1);
	}
	
}


%}
%union{
SymbolInfo* symbolInfo;
}


%token<symbolInfo> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token<symbolInfo> ID
%token<symbolInfo> CONST_INT CONST_FLOAT
%token<symbolInfo> ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON PRINTLN
%type<symbolInfo> start program unit var_declaration func_declaration type_specifier parameter_list func_definition compound_statement statements statement 
%type<symbolInfo> declaration_list expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor 
%type<symbolInfo> argument_list arguments


%left 
%right

%nonassoc 


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		$$ = new SymbolInfo("start" , $1->getType());
		
		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "start : program";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;
		logout << "Total Lines: " << lineCount << endl;
        logout << "Total Errors: " << errCount << endl;

		$$->addChild($1);

		printParseTree($$ , 1);
		
	}
	;



program : program unit
	{
		$$ = new SymbolInfo("program" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "program : program unit";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

	}

	| unit 
	{
		$$ = new SymbolInfo("program" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine  = "program : unit";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }
	;
	


unit : var_declaration
	{
		$$ = new SymbolInfo("unit" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unit : var_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}

    | func_declaration
	{
		$$ = new SymbolInfo("unit" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unit : func_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

    | func_definition
	{
		$$ = new SymbolInfo("unit" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unit : func_definition";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }
    ;



func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	{
		$$ = new SymbolInfo("func_declaration" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		string parseTreeLine = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);

	}

	| type_specifier ID LPAREN RPAREN SEMICOLON
	{
		$$ = new SymbolInfo("func_declaration" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		string parseTreeLine = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		
    }
	;



func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
	{
		$$ = new SymbolInfo("func_definition" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		string parseTreeLine = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
	}

	| type_specifier ID LPAREN RPAREN compound_statement
	{
		$$ = new SymbolInfo("func_definition" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		string parseTreeLine = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);

    }
 	;				



parameter_list  : parameter_list COMMA type_specifier ID
	{
		$$ = new SymbolInfo("parameter_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "parameter_list  : parameter_list COMMA type_specifier ID" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

	}
		
	| parameter_list COMMA type_specifier
	{
		$$ = new SymbolInfo("parameter_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }

 	| type_specifier ID
	{
		$$ = new SymbolInfo("parameter_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "parameter_list : type_specifier ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "parameter_list  : type_specifier ID" << endl;

		$$->addChild($1);
		$$->addChild($2);

    }
	
	| type_specifier
	{
		$$ = new SymbolInfo("parameter_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "parameter_list  : type_specifier";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }
 	;



compound_statement : LCURL statements RCURL
	{
		$$ = new SymbolInfo("compound_statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "compound_statement : LCURL statements RCURL";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		table.PrintAllScopeTable(parse_out);//have to fix the error part and all insertion in table

	}

 	| LCURL RCURL
	{
        $$ = new SymbolInfo("compound_statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "compound_statement : LCURL RCURL";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);     
    }
 	;



var_declaration : type_specifier declaration_list SEMICOLON
	{

		$$ = new SymbolInfo("var_declaration" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine =  "var_declaration : type_specifier declaration_list SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

	}
 	;



type_specifier	: INT
	{
		$$ = new SymbolInfo("type_specifier" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier	: INT";
		$$->setParseTreeLine("type_specifier : INT");
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}

 	| FLOAT
	{
		$$ = new SymbolInfo("type_specifier" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : FLOAT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: FLOAT" << endl;

		$$->addChild($1);

    }

 	| VOID
	{
		$$ = new SymbolInfo("type_specifier" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : VOID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: VOID" << endl;

		$$->addChild($1);

    }
 	;
 		


declaration_list : declaration_list COMMA ID
	{

		$$ = new SymbolInfo("declaration_list" , $1->getType());

		$$->setStartLine($1->getEndLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "declaration_list : declaration_list COMMA ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

	}

 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo("declaration_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		string parseTreeLine = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
			
    }

 	| ID
	{
			
		$$ = new SymbolInfo("declaration_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "declaration_list : ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

 	| ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo("declaration_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

    }
 	;



statements : statement
	{
		$$ = new SymbolInfo("statements" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statements : statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}
	   
	| statements statement
	{
		$$ = new SymbolInfo("statements" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "statements : statements statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    }
	;
	   


statement : var_declaration
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : var_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}
	  
	| expression_statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : expression_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

	| compound_statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
    }

	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		string parseTreeLine = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$$->addChild($7);

    }
	  
	| IF LPAREN expression RPAREN statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		string parseTreeLine = "statement : IF LPAREN expression RPAREN statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
    }
	  
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		string parseTreeLine = "statement : IF LPAREN expression RPAREN statement ELSE statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$$->addChild($7);

    }
	  
	| WHILE LPAREN expression RPAREN statement
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		string parseTreeLine = "statement : WHILE LPAREN expression RPAREN statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
    }
	  
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		string parseTreeLine = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
    }

	| RETURN expression SEMICOLON
	{
		$$ = new SymbolInfo("statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "statement : RETURN expression SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
    }
	;



expression_statement 	: SEMICOLON
	{
		$$ = new SymbolInfo("expression_statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "expression_statement 	: SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
	}	

	| expression SEMICOLON
	{
		$$ = new SymbolInfo("expression_statement" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "expression_statement : expression SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    }
	;
	  


variable : ID
	{
		$$ = new SymbolInfo("variable" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "variable : ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}

	| ID LSQUARE expression RSQUARE
	{
		$$ = new SymbolInfo("variable" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "variable : ID LSQUARE expression RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

    }
	;
	 


 expression : logic_expression
 	{
		$$ = new SymbolInfo("expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "expression : logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "expression 	: logic_expression" << endl;

		$$->addChild($1);
 	}	

	| variable ASSIGNOP logic_expression
	{
		$$ = new SymbolInfo("expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "expression : variable ASSIGNOP logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "expression 	: variable ASSIGNOP logic_expression " << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }	
	;



logic_expression : rel_expression
	{
		$$ = new SymbolInfo("logic_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "logic_expression : rel_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
	}

	| rel_expression LOGICOP rel_expression
	{
		$$ = new SymbolInfo("logic_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "logic_expression : rel_expression LOGICOP rel_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }	
	;
			


rel_expression	: simple_expression
	{
		$$ = new SymbolInfo("rel_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "rel_expression : simple_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "rel_expression	: simple_expression" << endl;

		$$->addChild($1);

	} 

	| simple_expression RELOP simple_expression
	{
		$$ = new SymbolInfo("rel_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "rel_expression : simple_expression RELOP simple_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "rel_expression	: simple_expression RELOP simple_expression" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }
	;



simple_expression : term
	{
		$$ = new SymbolInfo("simple_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "simple_expression : term";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
	}
		  
	| simple_expression ADDOP term
	{
		$$ = new SymbolInfo("simple_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "simple_expression : simple_expression ADDOP term";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }
	;



term :	unary_expression
	{
		$$ = new SymbolInfo("term" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "term : unary_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "term :	unary_expression" << endl;

		$$->addChild($1);
	}
     
	|  term MULOP unary_expression
	{
		$$ = new SymbolInfo("term" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "term : term MULOP unary_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "term :	term MULOP unary_expression" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

	}
    ;



unary_expression : ADDOP unary_expression
	{
		$$ = new SymbolInfo("unary_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "unary_expression : ADDOP unary_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		
	} 
		 
	| NOT unary_expression
	{
		$$ = new SymbolInfo("unary_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "unary_expression : NOT unary_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
    } 
		 
	| factor 
	{
		$$ = new SymbolInfo("unary_expression" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unary_expression : factor";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
    }
	;
	


factor	: variable
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : variable";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: variable" << endl;

		$$->addChild($1);

	}

	| ID LPAREN argument_list RPAREN
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "factor : ID LPAREN argument_list RPAREN";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

    }

	| LPAREN expression RPAREN
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "factor : LPAREN expression RPAREN";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: LPAREN expression RPAREN" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		
    }

	| CONST_INT
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : CONST_INT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_INT " << endl;

		$$->addChild($1);

    }

	| CONST_FLOAT
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : CONST_FLOAT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_FLOAT" << endl;

		$$->addChild($1);

    }

	| variable INCOP
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor	: variable INCOP";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    } 

	| variable DECOP
	{
		$$ = new SymbolInfo("factor" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor	: variable DECOP";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    }
	;
	


argument_list : arguments
	{
		$$ = new SymbolInfo("argument_list" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "argument_list : arguments";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		
	}

	|
	{

	}
	;
	

arguments : arguments COMMA logic_expression
	{
		$$ = new SymbolInfo("arguments" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "arguments : arguments COMMA logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

	}
	
	| logic_expression
	{
		$$ = new SymbolInfo("arguments" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "arguments : logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		
    }
	;
 


%%


int main(int argc,char *argv[])
{
	FILE* fp = fopen(argv[1] , "r");

	if(fp == NULL)
	{
		printf("Cannot Open Input File");
		exit(1);
	}

	logout.open("log.txt");
    error_out.open("error.txt");
    parse_out.open("parse_tree.txt");
	

	yyin=fp;
	yyparse();
	
	
	return 0;
}

