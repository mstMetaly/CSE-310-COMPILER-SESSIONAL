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
SymbolInfo_Details symbol_details;
SymbolInfo_Details parameter_details;
SymbolInfo_Details function_details;

void yyerror(const char *s)
{
	//write your code
    //printf("In yyerror:");
}


//checks if the id already inserted or not in the current scope
bool is_already_inserted(string name)
{
	SymbolInfo* symbolInfo = table.Lookup_current(name);
	
	if(symbolInfo == nullptr)
		return false;
	else 
		return true;
}

//gets already inserted id type
string get_id_type(string name)
{
	SymbolInfo* symbolInfo = table.Lookup_current(name);
	return symbolInfo->getType();
}

//inserts id into symbol table
void insertID_into_symbolTable(string name , string type)
{
	bool inserted = table.Insert(name , type);

	if(!inserted)
	{
		//error_out << "" << endl;
	}
	
}

//check function declaration
void check_function_declaration(string func_name , string func_ret_type , int line)
{
	if(table.Insert(func_name , "FUNCTION"))
		{
			SymbolInfo* symbol_info = table.Lookup(func_name);

			SymbolInfo_Details function_details;

			function_details.setName(func_name);
			function_details.setType("FUNCTION");
			function_details.setType(func_ret_type);

			vector<SymbolInfo_Details>parameter_list = parameter_details.get_parameter_list();

			for(int i = 0 ; i< parameter_details.get_parameterList_size() ; i++)
			{
				function_details.push_back_parameterList(parameter_list[i].getName() , parameter_list[i].getType());
			}

			symbol_info->symbolInfo_details = function_details;

		}
		else
		{
			//get the same name id at currentScope
			if(table.Lookup_current(func_name))
			{
				SymbolInfo* symbol_info = table.Lookup_current(func_name);

				if(symbol_info->getType()=="FUNCTION")
				{
					error_out << "Line# " << line << ": \'" <<func_name << "\' redeclared as different kind of symbol" << endl;
				}
				else
				{
					error_out << "Line# " << line << ": \'" <<func_name << "\' redeclared as different kind of symbol" << endl;
				}

			}
			else{
				
				SymbolInfo* symbol_info = table.Lookup(func_name);

				if(symbol_info->getType()=="FUNCTION")
				{
					error_out << "Line# " << line << ": \'" << func_name << "\' redeclared as different kind of symbol" << endl;
				}
				else{
					 //global variable and func_name can't be similar
					error_out << "Line# " << line << ": \'" << func_name << "\' redeclared as different kind of symbol" << endl;
				}

			}

		}

}


//check function definiton
void check_function_definition(string func_name , string func_ret_type , int line)
{
	if(table.Lookup(func_name))
	{
		SymbolInfo* symbol_info = table.Lookup(func_name);

		if(symbol_info->getType() == "FUNCTION")
		{
			//have to check the parameter type , number etc
			//gets the already declared function, parameter list is the already declared function's parameter list
			vector<SymbolInfo_Details>already_parameter_list = (symbol_info->symbolInfo_details).get_parameter_list();

			if(already_parameter_list.size() != parameter_details.get_parameterList_size())
			{
				//error_out << "Line# " << line << ": Too few arguments to function \'" << func_name << "\'" << endl;
				error_out << "Line# " << line << ": Conflicting types for \'" << func_name <<"\'" << endl;
			}
			else
			{
				vector<SymbolInfo_Details>current_parameter_list = (symbol_info->symbolInfo_details).get_parameter_list();
				//checks the parameter type
				for(int i=0; i<current_parameter_list.size() ; i++)
				{
					if(current_parameter_list[i].getType() != already_parameter_list[i].getType())
						error_out << "Line# " << line << ": Conflicting types for \'" << func_name <<"\'" << endl;
						//error_out << "" <<  endl;
				}

			}
		}
		
	}
	else{
		//error_out << "Line# " << line << ": Undeclared function \'" << func_name  << "\'" << endl;
		check_function_declaration(func_name, func_ret_type , line);
	}

}

//prints the parse tree
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


//have to check function parameter redefination, return type should be store ,also function name will be stored.
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

		string func_name = $2->getName();
		string func_ret_type = $1->getType();

		//checks the function name already inserted or not
		check_function_declaration(func_name , func_ret_type , $1->getStartLine());

		
		SymbolInfo_Details parameter;
		parameter_details = parameter;

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

		string func_name = $2->getName();
		string func_ret_type = $1->getType();

		//checks the function name already inserted or not
		check_function_declaration(func_name , func_ret_type , $1->getStartLine());

		SymbolInfo_Details parameter;
		parameter_details = parameter;
		
    }
	;


//have to check function name , whether return type matched or not etc
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

		string func_name = $2->getName();
		string func_ret_type = $1->getType();

		check_function_definition(func_name , func_ret_type , $1->getStartLine());

		SymbolInfo_Details parameter;
		parameter_details = parameter;
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

		string func_name = $2->getName();
		string func_ret_type = $1->getType();

		check_function_definition(func_name , func_ret_type , $1->getStartLine());

		SymbolInfo_Details parameter;
		parameter_details = parameter;

    }
 	;				


//have to check parameter redefination,whether type is void or not
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

		if($3->getType() == "VOID")
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $4->getName() << "\' declared void" << endl;
		else{
			if(parameter_details.already_in_parameterList($4->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \' " << $4->getName() << "\'" << endl;
			}
			else{
				parameter_details.push_back_parameterList($4->getName() , $3->getType());
			}

		}

	}
		
	| parameter_list COMMA type_specifier
	{
		$$ = new SymbolInfo($1->getName() + ","+ $3->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		if($3->getType() == "VOID")
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $1->getName() << "\' declared void" << endl;

    }

 	| type_specifier ID
	{
		$$ = new SymbolInfo($1->getName()+ $2->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "parameter_list : type_specifier ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "parameter_list  : type_specifier ID" << endl;

		$$->addChild($1);
		$$->addChild($2);

		if($1->getType() == "VOID")
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $1->getName() << "\' declared void" << endl;
		else{
			if(parameter_details.already_in_parameterList($2->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \' " << $2->getName() << "\'" << endl;
			}
			else{
				parameter_details.push_back_parameterList($2->getName() , $1->getType());
			}

		}

    }
	
	| type_specifier
	{
		$$ = new SymbolInfo($1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "parameter_list  : type_specifier";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		if($1->getType() == "VOID")
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $1->getName() << "\' declared void" << endl;


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

		table.PrintAllScopeTable(logout);//have to fix the error part and all insertion in table
		table.ExitScope();

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


//error fixed--
var_declaration : type_specifier declaration_list SEMICOLON
	{

		$$ = new SymbolInfo($1->getName() + $2->getName() + ";" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine =  "var_declaration : type_specifier declaration_list SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);


		if($1->getType() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $2->getName() << "\' declared void" << endl;
		}

		SymbolInfo_Details new_obj;
		symbol_details = new_obj;


	}
 	;



type_specifier	: INT
	{
		$$ = new SymbolInfo($1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier	: INT";
		$$->setParseTreeLine("type_specifier : INT");
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//sets id type
		symbol_details.setType($1->getType());

	}

 	| FLOAT
	{
		$$ = new SymbolInfo($1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : FLOAT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: FLOAT" << endl;

		$$->addChild($1);

		//sets id type
		symbol_details.setType($1->getType());

    }

 	| VOID
	{
		$$ = new SymbolInfo($1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : VOID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: VOID" << endl;

		$$->addChild($1);

		//sets id type
		symbol_details.setType($1->getType());

    }
 	;
 		


declaration_list : declaration_list COMMA ID
	{

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() , $1->getType());

		$$->setStartLine($1->getEndLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "declaration_list : declaration_list COMMA ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);


		if(symbol_details.getType() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $3->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($3->getName()))
			{
				//have to check type  of redeclaration
				if(get_id_type($3->getName()) == $3->getType())
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;
				else
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
			}
			else{
				insertID_into_symbolTable($3->getName() , $3->getType());
			}
		}

	}

 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() + "[" + $5->getName() + "]" , $1->getType());

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

		if(symbol_details.getType() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $3->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($3->getName()))
			{
				if(get_id_type($3->getName()) == $3->getType())
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
			}
			else{
				insertID_into_symbolTable($3->getName() , $3->getType());
				symbol_details.set_is_array(true);
			}
		}
			
    }

 	| ID
	{
			
		$$ = new SymbolInfo($1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "declaration_list : ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//inserts id into symbol table
		if(symbol_details.getType() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) == $1->getType())
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
			}
			else{
				insertID_into_symbolTable($1->getName() , $1->getType());
			}
		}

		

    }

 	| ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo($1->getName() + "[" + $3->getName()+ "]" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

		if(symbol_details.getType() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) == $1->getType())
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
			}
			else{
				insertID_into_symbolTable($1->getName() , $1->getType());
				symbol_details.set_is_array(true);
			}
		}

    }
 	;

//--error fixed

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
		logout << "factor	: ID LPAREN argument_list RPAREN" << endl;

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

