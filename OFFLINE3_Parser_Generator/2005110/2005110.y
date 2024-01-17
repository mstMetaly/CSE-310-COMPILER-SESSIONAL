%{
#include<bits/stdc++.h>
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
bool check = true;



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

bool do_insert = false;


//check variable 
void check_variable(string name , string type , int line)
{
	SymbolInfo* symbol_info = table.Lookup(name);

	if(symbol_info== nullptr)
	{
		error_out << "Line# " << line << ": Undeclared variable \' " << name << "\'" << endl;
	}
	
}

//check is array 
void check_is_array(string name , string type , int line)
{
	SymbolInfo* symbol_info = table.Lookup(name);

	if(symbol_info != nullptr)
	{
		SymbolInfo_Details details_obj = symbol_info->symbolInfo_details;

		if(!details_obj.check_is_array())
		{
			error_out << "Line# " << line << ": \'" << name << "\' is not an array" << endl;
		}
		else{
			//check array subscript
			if(type != "INT")
			{
				error_out << "Line# " <<  line << ": Array subscript is not an integer" << endl;
			}
		}
	}

}


//inserts the function definition
void check_function_declaration(string func_name , string func_type , int line, int val)
{
	SymbolInfo* symbol_info = table.Lookup_current(func_name);

	if(symbol_info == nullptr)
	{
		table.Insert(func_name,"FUNCTION");

		SymbolInfo* func_obj = table.Lookup_current(func_name);

		SymbolInfo_Details details_obj;
		details_obj.set_is_defined(true);//func has a definition 

		vector<SymbolInfo_Details>parameter_list = symbol_details.get_parameter_list();

		for(int i=0;i<parameter_list.size();i++)
		{
			details_obj.push_back_parameterList(parameter_list[i].getName() , parameter_list[i].getType());
		}

		details_obj.set_func_ret_type(func_type);
		func_obj->symbolInfo_details = details_obj;

	}
	else{
		error_out << "Line# " << line << ": \'" << func_name << "\'" << "redeclared as different kind of symbol" << endl;
	}


}


//check parameter validity
void check_parameter_validity(int line)
{
	vector<SymbolInfo_Details>parameter_list = symbol_details.get_parameter_list();

	for(int i=0;i<parameter_list.size();i++)
	{
		//have to check is parameter type is void	
	}

	for(int i=0;i<parameter_list.size();i++)
	{
		if(!function_details.already_in_parameterList(parameter_list[i].getName()))
		{
			function_details.push_back_parameterList(parameter_list[i].getName(),parameter_list[i].getType());
		}
		else
		{
			function_details.set_is_error_function(true);
			break;
		}
		
	}

}

//checks the return type,parameter type for defined function
void check_function_definition(string func_name , string func_type , int line )
{
	function_details.setName(func_name);
	function_details.set_func_ret_type(func_type);
	function_details.set_is_defined(false);
	function_details.set_is_declared(false);
	function_details.set_is_error_function(false);

	SymbolInfo* symbol_info = table.Lookup(func_name);

	//there exists no function with this func name ,so can be inserted
	if(symbol_info==nullptr)
	{
		function_details.set_is_declared(true);//declare = true , define = false
		//checks the parameters are redeclared or not
		check_parameter_validity(line);

	}
	else{
		if(symbol_info->getType()=="FUNCTION")
		{
			SymbolInfo_Details details_obj = symbol_info->symbolInfo_details;

			//the function has a definition , so now have to check return type and parameter type
			if(details_obj.get_is_defined()==true && details_obj.get_is_declared()==false)
			{
				//check return type and parameter 
				if(details_obj.getFuncType() != func_type)
				{
					error_out << "Line# " << line <<": Conflicting types for \'" << func_name << "\'" << endl;
					//function_details.set_is_error_function(true);
				}
				else
				{
					vector<SymbolInfo_Details>defined_parameter_list = details_obj.get_parameter_list();
					vector<SymbolInfo_Details>current_parameter_list = symbol_details.get_parameter_list();

					if(defined_parameter_list.size() != current_parameter_list.size())
					{
						error_out << "Line# " << line <<": Conflicting types for \'" << func_name << "\'" << endl;
					}
					else
					{
						for(int i=0;i<defined_parameter_list.size();i++)
						{
							if(defined_parameter_list[i].getType() != current_parameter_list[i].getType())
							{
								error_out << "Line# " << line <<": Conflicting types for \'" << func_name << "\'" << endl;
							}
						}
					}
					
				}

				function_details.set_is_declared(true);
				function_details.set_is_defined(true);
			}
		}

		else
		{
			//another variable exist with this function name
			error_out << "Line# " << line << ": \'" << func_name << "\' redeclared as different kind of symbol" << endl;
		}


	}

	

}


//adds parameter to the defined function
void add_parameter_to_func(string func_name,string ret_type)
{
	SymbolInfo* symbol_info = table.Lookup(func_name);

	SymbolInfo_Details details_obj;

	if(function_details.get_is_error_function())
	{
		vector<SymbolInfo_Details>parameter_list = function_details.get_parameter_list();

		for(int i=0;i<parameter_list.size();i++)
		{
			details_obj.push_back_parameterList(parameter_list[i].getName(),parameter_list[i].getType());
		}
	}
	else{
		vector<SymbolInfo_Details>parameter_list = symbol_details.get_parameter_list();

		for(int i=0;i<parameter_list.size();i++)
		{
			details_obj.push_back_parameterList(parameter_list[i].getName(),parameter_list[i].getType());
		}
	}

	details_obj.set_func_ret_type(ret_type);
	symbol_info->symbolInfo_details = details_obj;

}


//checks factor: function call
/*
 void check_factor_function(string name , string type , int line)
{
	SymbolInfo* symbol_info = table.Lookup(name);

	if(symbol_info == nullptr)
	{
		error_out << "Line# " << line << ": Undeclared function \'" << name << "\'" << endl;
	}
	else{ 
		if(symbol_info->getType() == "FUNCTION")
		{
			SymbolInfo_Details symbolInfo_details = symbol_info->symbolInfo_details;

			vector<SymbolInfo_Details> parameter_list = (symbol_info->symbolInfo_details).get_parameter_list();
			vector<SymbolInfo_Details> argument_list = parameter_details.get_argument_list();

			
			//check parameter list size ans type
			if( argument_list.size() < parameter_list.size() )
			{
				error_out << "Line# " << line << ": Too few arguments to function \' "<<  name << "\'" << endl;
			}
			else if( argument_list.size() > parameter_list.size())
			{
				error_out << "Line# " << line << ": Too many arguments to function \' "<<  name << "\'" << endl;
			}
			else
			{
				cout << symbol_info->getName() << endl;
			//check argument and parameter type
				for(int i=0;i < parameter_list.size() ; i++)
				{	
					string argument_type = argument_list[i].getType();

					if(argument_type == "CONST_INT")
						argument_type = "INT";
					else if(argument_type == "CONST_FLOAT")
						argument_type = "CONST_FLOAT";

					if(parameter_list[i].getType() != argument_type)
					{
						cout << parameter_list[i].getType() << "    argument: "<<argument_list[i].getName() << "   " << argument_list[i].getType() << endl;
						error_out << "Line# " << line << ": Type mismatch for argument " << i+1<<" of \'" << name << "\'" << endl;
					}
				}
			}
		

		}
		else{
			error_out  << "Line# " << line << ": \'" << name << "\' is not function" << endl;
		}

	}

}
*/



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
%type<symbolInfo> argument_list arguments new_scope


%left ASSIGNOP
%left LOGICOP
%left RELOP
%left ADDOP
%left MULOP
%right NOT
%right INCOP DECOP

%nonassoc 


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		$$ = new SymbolInfo("program" , $1->getType());
		
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
		$$ = new SymbolInfo("program unit" , $1->getType());

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
		$$ = new SymbolInfo("unit" , $1->getType());

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
		$$ = new SymbolInfo("var_declaration" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unit : var_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}

    | func_declaration
	{
		$$ = new SymbolInfo("func_declaration" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "unit : func_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

    | func_definition
	{
		$$ = new SymbolInfo("func_definition" , $1->getType());

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
		$$ = new SymbolInfo($1->getName() + $2->getName() + "(" + $4->getName() + ")" + ";" , $1->getType());

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
		check_function_declaration(func_name , func_ret_type , $1->getStartLine(),0);

		symbol_details.clear_parameter_list();

		SymbolInfo_Details obj;
		function_details = obj;


	}

	| type_specifier ID LPAREN RPAREN SEMICOLON
	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + "(" + ")" + ";" , $1->getType());

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
		check_function_declaration(func_name , func_ret_type , $1->getStartLine(),0);

		symbol_details.clear_parameter_list();

		SymbolInfo_Details obj;
		function_details = obj;
		
    }
	;


//have to check function name , whether return type matched or not etc
func_definition : type_specifier ID LPAREN parameter_list RPAREN {string function_name = $2->getName();string function_ret_type = $1->getType();int line = $1->getStartLine();check_function_definition(function_name , function_ret_type,line);}compound_statement{
//func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement{
		string fname = $1->getName() + $2->getName() + "(" + $4->getName() + ")" + $7->getName();
		string ftype = $1->getType();

		$$ = new SymbolInfo(fname , ftype);

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		string parseTreeLine = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($7);

		string func_name = $2->getName();
		string func_ret_type = $1->getType();


		//insert the func id
		if(function_details.get_is_declared()==true && function_details.get_is_defined()==false)
		{
			table.Insert(function_details.getName(), "FUNCTION");
			//add parameters to function
			add_parameter_to_func(function_details.getName() , ftype);
		}
			
		
		symbol_details.clear_parameter_list();
		SymbolInfo_Details obj;
		function_details = obj;

	}

	| type_specifier ID LPAREN RPAREN{string func_name = $2->getName();string ret_type = $1->getType();check_function_definition(func_name , ret_type , $1->getStartLine());} compound_statement
	{

		$$ = new SymbolInfo( $1->getName() + $2->getName() + "(" + ")" + $6->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		string parseTreeLine = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($6);

		string func_name = $2->getName();
		string func_ret_type = $1->getType();

		if(function_details.get_is_declared()==true && function_details.get_is_defined()==false)
		{
			table.Insert(function_details.getName(), "FUNCTION");
			//add parameters to function
			add_parameter_to_func(function_details.getName() ,$1->getType());
		}

		//check and insert func id
		//check_function_definition(func_name , func_ret_type , $1->getStartLine());


		symbol_details.clear_parameter_list();
		SymbolInfo_Details obj;
		function_details = obj;

    }
 	;				



//final fixed

new_scope:{
	
	table.EnterScope();

	//inserts all the parameter of the declared function
	//if(function_details.get_is_declared()==true && function_details.get_is_defined()==false)
	//{
		vector<SymbolInfo_Details>current_parameter_list = symbol_details.get_parameter_list();
		vector<SymbolInfo_Details>error_parameter_list = function_details.get_parameter_list();
		if(function_details.get_is_error_function())
		{
			for(int i=0;i<error_parameter_list.size() ;i++)
			{
				table.Insert(error_parameter_list[i].getName() , error_parameter_list[i].getType());
			}
		}
		else
		{
			for(int i=0;i<current_parameter_list.size() ;i++)
			{
				table.Insert(current_parameter_list[i].getName() , current_parameter_list[i].getType());
			}
		}
		
	//}


	
}


//final fixed
//have to check parameter redefination,whether type is void or not
parameter_list  : parameter_list COMMA type_specifier ID
	{
		$$ = new SymbolInfo( $1->getName() + "," + $3->getName() + $4->getName() , $1->getType());//doesn't matter parameter list type cz we are inserting and have a parameter list in symbol info

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
			
			if(symbol_details.already_in_parameterList($4->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \'" << $4->getName() << "\'" << endl;
				symbol_details.push_back_parameterList($4->getName() , $3->getType());
			}
			else{
				symbol_details.push_back_parameterList($4->getName() , $3->getType());
			}


		}

	}
		
	| parameter_list COMMA type_specifier
	{
		$$ = new SymbolInfo($1->getName() + ","+ $3->getName() , $1->getType());//this doesn't matter

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		if($3->getType() == "VOID")
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << "" << "\' declared void" << endl;
		
		symbol_details.push_back_parameterList("",$3->getType());

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
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $2->getName() << "\' declared void" << endl;
		else{
			if(symbol_details.already_in_parameterList($2->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \'" << $2->getName() << "\'" << endl;
				symbol_details.push_back_parameterList($2->getName() , $1->getType());
			}
			else{
				symbol_details.push_back_parameterList($2->getName() , $1->getType());
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
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << "" << "\' declared void" << endl;
		
		symbol_details.push_back_parameterList("" , $1->getType());


    }
 	;



//final fixed
compound_statement : LCURL new_scope statements RCURL
	{
		$$ = new SymbolInfo( "{" + $2->getName() + "}" , $1->getType());//doesn't matter its type

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "compound_statement : LCURL statements RCURL";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($3);
		$$->addChild($4);
		


		table.PrintAllScopeTable(logout);
		table.ExitScope();

	}

 	| LCURL new_scope RCURL
	{
        $$ = new SymbolInfo("{}" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "compound_statement : LCURL RCURL";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($3); 

		table.PrintAllScopeTable(logout);//have to fix the error part and all insertion in table
		table.ExitScope();    
    }
 	;


//final fixed
var_declaration : type_specifier declaration_list SEMICOLON
	{

		$$ = new SymbolInfo($1->getName() + $2->getName() + ";" , symbol_details.get_variable_type());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine =  "var_declaration : type_specifier declaration_list SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);


		// if($1->getType() == "VOID")
		// {
		// 	error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $2->getName() << "\' declared void" << endl;
		// }

		symbol_details.set_variable_type("");


	}
 	;


//final fixed
type_specifier	: INT
	{
		$$ = new SymbolInfo($1->getName() , "INT");

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier	: INT";
		$$->setParseTreeLine("type_specifier : INT");
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("INT");

	}

 	| FLOAT
	{
		$$ = new SymbolInfo($1->getName() , "FLOAT");

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : FLOAT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: FLOAT" << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("FLOAT");

    }

 	| VOID
	{
		$$ = new SymbolInfo($1->getName() , "VOID");

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "type_specifier : VOID";
		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: VOID" << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("VOID");

    }
 	;
 		


//final fixed
declaration_list : declaration_list COMMA ID
	{

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() , symbol_details.get_variable_type());

		$$->setStartLine($1->getEndLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "declaration_list : declaration_list COMMA ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);


		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \'" << $3->getName() << "\'" << endl;
		}
		else{
			//checks already inserted in current scope or not
			if(is_already_inserted($3->getName()))
			{
				//have to check type  of redeclaration
				if(get_id_type($3->getName()) != symbol_details.get_variable_type())
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;
				else
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
			}
			else
			{
				insertID_into_symbolTable($3->getName() , symbol_details.get_variable_type());
			}
		}

	}

 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() + "[" + $5->getName() + "]" , symbol_details.get_variable_type());

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

		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \'" << $3->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($3->getName()))
			{
				if(get_id_type($3->getName()) != symbol_details.get_variable_type())
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
			}
			else
			{
				insertID_into_symbolTable($3->getName() , symbol_details.get_variable_type());
				SymbolInfo* symbol = table.Lookup($3->getName());
				(symbol->symbolInfo_details).set_is_array(true);
			}
		}
			
    }

 	| ID
	{
			
		$$ = new SymbolInfo($1->getName() , symbol_details.get_variable_type());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "declaration_list : ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		
		//inserts id into symbol table
		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
		}
		else if(symbol_details.get_variable_type() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $1->getName() <<"\' declared void" << endl;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) != symbol_details.get_variable_type())
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
			}
			else
			{
				insertID_into_symbolTable($1->getName() , symbol_details.get_variable_type());
			}
		}

		

    }

 	| ID LSQUARE CONST_INT RSQUARE
	{

		$$ = new SymbolInfo($1->getName() + "[" + $3->getName()+ "]" , symbol_details.get_variable_type());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) != symbol_details.get_variable_type())
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
				else 
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
			}
			else{
				insertID_into_symbolTable($1->getName() , symbol_details.get_variable_type());

				//symbol_details.set_is_array(true);
				SymbolInfo* symbol = table.Lookup($1->getName());
				(symbol->symbolInfo_details).set_is_array(true);

			}
		}

    }
 	;

//--error final fixed



statements : statement
	{
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statements : statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}
	   
	| statements statement
	{
		$$ = new SymbolInfo( $1->getName() + $2->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : var_declaration";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}
	  
	| expression_statement
	{
		$$ = new SymbolInfo( $1->getName(), $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : expression_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

	| compound_statement
	{
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "statement : compound_statement";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
    }

	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + $5->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + $5->getName() + $6->getName() + $7->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() +"(" + $3->getName() + ")" + $5->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + ";" , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() + $2->getName() + ";" , $1->getType());

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
		$$ = new SymbolInfo(";" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "expression_statement 	: SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//clear argument list
		parameter_details.clear_argument_list();
	}	

	| expression SEMICOLON
	{
		$$ = new SymbolInfo( $1->getName() + ";" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		string parseTreeLine = "expression_statement : expression SEMICOLON";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

		//clear argument list
		parameter_details.clear_argument_list();

    }
	;
	  

variable : ID
	{
		string var_name = $1->getName();
		string var_type = $1->getType();
		
		SymbolInfo* symbol_info = table.Lookup(var_name);

		if(symbol_info==nullptr)
		{
			error_out << "Line# " << $1->getStartLine() <<": Undeclared variable \'" << var_name <<"\'" << endl;
			$$ = new SymbolInfo(var_name , "undeclared");
		}
		else
		{
			string type = symbol_info->getType();
			$$ = new SymbolInfo(var_name ,type);
		}


		//$$ = new SymbolInfo( $1->getName() , var_type);

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "variable : ID";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

	}

	| ID LSQUARE expression RSQUARE
	{
		string var_name = $1->getName();
		string var_type = $1->getType();

		SymbolInfo* symbol_info = table.Lookup(var_name);

		if(symbol_info == nullptr)
		{
			error_out << "Line# " << $1->getStartLine() <<": Undeclared variable \'" << var_name <<"\'" << endl;
			$$ = new SymbolInfo(var_name , "undeclared");
		}
		else
		{
			SymbolInfo_Details details_obj = symbol_info->symbolInfo_details;

			if(details_obj.check_is_array())
			{
				string array_type = symbol_info->getType();

				string subscript_type = $3->getType();

				if(subscript_type!= "INT")
				{
					error_out << "Line# " <<  $1->getStartLine() << ": Array subscript is not an integer" << endl;
				}

				$$ = new SymbolInfo(var_name,array_type);
				
			}
			else
			{
				error_out << "Line# " << $1->getStartLine() << ": \'" << var_name << "\' is not an array" << endl;
				$$ = new SymbolInfo(var_name,var_type);
			}

		}

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		string parseTreeLine = "variable : ID LSQUARE expression RSQUARE";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

		//checks is it array or not , array subscript int or not , array declared or not etc.
		string name = $1->getName();
		string subscript_type = $3->getType();
		string type = symbol_details.get_variable_type();


    }
	;


 expression : logic_expression
 	{
		$$ = new SymbolInfo( $1->getName(), $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "expression : logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "expression 	: logic_expression" << endl;

		$$->addChild($1);
 	}	

	| variable ASSIGNOP logic_expression
	{
		//checks  Generate error message if operands of an assignment operator are not consistent with each
		//other. Note that, the second operand of the assignment operator will be an expression that
		//may contain numbers, variables, function calls, etc.
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = operand2_type;


		if(operand1_type == "VOID" || operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
		else if(operand1_type == "INT" && operand2_type== "FLOAT")
		{
			error_out << "Line# " << lineCount << ": Warning: possible loss of data in assignment of FLOAT to INT" << endl;
			type = "INT";
		}
		else if(operand1_type == "FLOAT" && operand2_type== "FLOAT")
		{
			type = "FLOAT";
		}

		
		$$ = new SymbolInfo( $1->getName() + "=" + $3->getName() , type);

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "logic_expression : rel_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
	}

	| rel_expression LOGICOP rel_expression
	{
		//checks the result of LOGICOP should be integer
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = "INT";

		if(operand1_type == "VOID")
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		else if(operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
		else
		{
			//handleTypeCastAvoidCheck($1,$3,"Type mismatch");
		}

		$$ = new SymbolInfo( $1->getName() + $2->getName() + $3->getName() , type);

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "rel_expression : simple_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "rel_expression	: simple_expression" << endl;

		$$->addChild($1);

	} 

	| simple_expression RELOP simple_expression
	{
		//checks the result of RELOP should be an integer
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = "INT";

		if(operand1_type == "VOID")
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		else if(operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
		else
		{
			//handleTypeCastAvoidCheck($1,$3,"Type mismatch");
		}

		$$ = new SymbolInfo( $1->getName() + $2->getName() + $3->getName() , type);

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "simple_expression : term";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
	}
		  
	| simple_expression ADDOP term
	{
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = operand1_type;

		if(operand1_type == "VOID")
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		else if(operand2_type == "VOID")
		{
			type = operand1_type;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;

		}
		else
		{
			//handleTypeCastAvoidCheck($1,$3,"Type mismatch");
		}
		
		//handleTypeCheck(left symbol,right symbol)

		$$ = new SymbolInfo( $1->getName() +  $2->getType() + $3->getName() , type);

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "term : unary_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << "term :	unary_expression" << endl;

		$$->addChild($1);
	}
     
	|  term MULOP unary_expression
	{
		//checks both operands for modulus int or not , disision by zero or not

		string addop_symbol = $2->getName();
		string operand1_type = $2->getType();
		string operand2_name = $3->getName();
		string operand2_type = $3->getType();

		string type = operand2_type;

		if(operand1_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
		else if(operand2_type == "VOID")
		{
			type = operand1_type;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
		else if(addop_symbol == "/")
		{
			if(operand2_name == "0")
				error_out << "Line# " << lineCount << ": Warning: division by zero i=0f=1Const=0" << endl;

		}
		else if(addop_symbol == "%")
		{
			if(operand2_name == "0")
				error_out << "Line# " << lineCount << ": Warning: division by zero i=0f=1Const=0" << endl;
			else if(operand1_type != "INT " || operand2_type!= "INT")
				error_out << "Line# " << lineCount << ": Operands of modulus must be integers" << endl;
			
			type = "INT";
		}
		else
		{
			//handleTypeCastAvoidCheck($1,$3,"Type mismatch");
		}


		$$ = new SymbolInfo( $1->getName() + $2->getType() + $3->getName() , type);

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
		$$ = new SymbolInfo( $1->getType() + $2->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getType() + $2->getName() , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() , $1->getType());

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
		string variable_type = $1->getType();

		$$ = new SymbolInfo( $1->getName() , variable_type);

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : variable";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: variable" << endl;

		$$->addChild($1);

	}

	| ID LPAREN argument_list RPAREN
	{
		string name = $1->getName();
		string type = $1->getType();

		string factor_name = $1->getName() + "("+$3->getName() + ")";

		SymbolInfo* symbol_info = table.Lookup(name);

		if(symbol_info == nullptr)
		{
			error_out << "Line# " << lineCount << ": Undeclared function \'" << name << "\'" << endl;
			$$ = new SymbolInfo( factor_name,  "undeclared");
		}
		else if(symbol_info->getType()=="FUNCTION")
		{

			SymbolInfo_Details symbol_info_details = symbol_info->symbolInfo_details;
			string func_return_type = symbol_info_details.getFuncType();

			$$ = new SymbolInfo( factor_name, func_return_type);

			vector<SymbolInfo_Details> parameter_list = (symbol_info->symbolInfo_details).get_parameter_list();
			vector<SymbolInfo_Details> argument_list = parameter_details.get_argument_list();


			//check parameter list size ans type
			if( argument_list.size() < parameter_list.size() )
			{
				error_out << "Line# " << lineCount << ": Too few arguments to function \'"<<  name << "\'" << endl;
			}
			else if( argument_list.size() > parameter_list.size())
			{
				error_out << "Line# " << lineCount << ": Too many arguments to function \'"<<  name << "\'" << endl;
			}
			else
			{
				//check argument and parameter type
				for(int i=0;i < parameter_list.size() ; i++)
				{	
					string argument_type = argument_list[i].getType();

					if(parameter_list[i].getType() != argument_type)
					{
						error_out << "Line# " << lineCount << ": Type mismatch for argument " << i+1<<" of \'" << name << "\'" << endl;
					}
				}
			}

		}
		else{

			error_out << "Line# " << lineCount << ": is not a function \' "<<  name << "\'" << endl;
			$$ = new SymbolInfo( factor_name ,"not function");
		}
			
	

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
		$$ = new SymbolInfo( "(" + $2->getName() + ")" , $1->getType());

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
		$$ = new SymbolInfo( $1->getName() , "INT");

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : CONST_INT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_INT " << endl;

		$$->addChild($1);

    }

	| CONST_FLOAT
	{
		$$ = new SymbolInfo( $1->getName(),  "FLOAT");

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor : CONST_FLOAT";
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_FLOAT" << endl;

		$$->addChild($1);

    }

	| variable INCOP
	{
		$$ = new SymbolInfo( $1->getName() + "++" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor	: variable INCOP";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

		//check_factor_incop

    } 

	| variable DECOP
	{
		$$ = new SymbolInfo( $1->getName()+ "--" , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "factor	: variable DECOP";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

		//check_factor_decop

    }
	;
	

//fixed
argument_list : arguments
	{
		$$ = new SymbolInfo( $1->getName() , $1->getType());

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
	
//fixed
arguments : arguments COMMA logic_expression
	{
		$$ = new SymbolInfo( $1->getName() + "," +  $3->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		string parseTreeLine = "arguments : arguments COMMA logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		//pushing the argument
		
		string name = $3->getName();
		string type = $3->getType();
		
		parameter_details.push_back_argumentList(name , type);


	}
	
	| logic_expression
	{
		$$ = new SymbolInfo( $1->getName() , $1->getType());

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		string parseTreeLine = "arguments : logic_expression";
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		
		string name = $1->getName();
		string type = $1->getType();

		//extra
		string var_name = $1->getName();
		string var_type = $1->getType();

		string substring = "[";

		if (var_name.find(substring) != std::string::npos)
		{
			size_t pos = var_name.find('[');

    		if (pos != std::string::npos) 
			{
        		// Extract the substring before the '[' character
        		var_name = var_name.substr(0, pos);
    		}
		}

		SymbolInfo* symbol_info = table.Lookup(var_name);
		
		if(symbol_info!=nullptr)
		{
			var_type = symbol_info->getType();
		}

		parameter_details.push_back_argumentList(var_name , var_type);

	
    }
	;
 


%%


int main(int argc,char *argv[])
{
	//updated
	FILE* fp = fopen(argv[1] , "r");

	if(fp == NULL)
	{
		printf("Cannot Open Input File");
		exit(1);
	}

	logout.open("log.txt");
    error_out.open("error.txt");
    parse_out.open("parsetree.txt");
	

	yyin=fp;
	yyparse();
	
	
	return 0;
}

