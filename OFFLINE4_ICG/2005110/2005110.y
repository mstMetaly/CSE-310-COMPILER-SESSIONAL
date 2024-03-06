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
int errorCount = 0;
ofstream error_out;
ofstream parse_out;

ofstream assembly_out;

extern SymbolTable table;
SymbolInfo_Details symbol_details;
SymbolInfo_Details parameter_details;
SymbolInfo_Details function_details;
bool check = true;


int offsetCount = 0;
unordered_map<string,int>offsetMap;

int varOffset = 0;
SymbolTable parseTable(11);
int curr_id = 1;

int variableCount = 0;

int var_width=0;
vector<SymbolInfo*>global_variable_list;

string trueLevel = "";
string falseLevel =  "";
string endLevel = "";
int levelCount = 0;
bool condition_flag = false ;
string true_level="";
string false_level="";
unordered_map<string,int>parameterlist;
int paramOffset = 1;
bool paramFlag=false;
bool returnFlag=false;

void yyerror(const char *s)
{
	//write your code
    //printf("In yyerror:");
}

string newLabel()
{
	levelCount++;
	string l = "L"+ to_string(levelCount);
	return  l;
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
		errCount++;
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
			errorCount++;
		}
		else{
			//check array subscript
			if(type != "INT")
			{
				error_out << "Line# " <<  line << ": Array subscript is not an integer" << endl;
				errorCount++;
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
		errorCount++;
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
					errorCount++;
				}
				else
				{
					vector<SymbolInfo_Details>defined_parameter_list = details_obj.get_parameter_list();
					vector<SymbolInfo_Details>current_parameter_list = symbol_details.get_parameter_list();

					if(defined_parameter_list.size() != current_parameter_list.size())
					{
						error_out << "Line# " << line <<": Conflicting types for \'" << func_name << "\'" << endl;
						errorCount++;
					}
					else
					{
						for(int i=0;i<defined_parameter_list.size();i++)
						{
							if(defined_parameter_list[i].getType() != current_parameter_list[i].getType())
							{
								error_out << "Line# " << line <<": Conflicting types for \'" << func_name << "\'" << endl;
								errorCount++;
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
			errorCount++;
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

 string getOpcode(string op){
        string opcode = "";
        if(op == "<") opcode ="\tJL";
        else if(op == ">") opcode ="\tJG";
        else if(op == ">=") opcode ="\tJGE";
        else if(op == "<=") opcode ="\tJLE";
        else if(op == "==") opcode ="\tJE";
        else if(op == "!=") opcode ="\tJNE";
        return opcode;
    }


void newLine()
{
	assembly_out << "new_line PROC\n\tPUSH AX\n\tPUSH DX\n\tMOV AH,2\n\tMOV DL,CR\n\tINT 21H\n\tMOV AH,2\n\tMOV DL,LF\n\tINT 21H\n\tPOP DX\n\tPOP AX\n\tRET\nnew_line ENDP\n";

}

void println()
{
	assembly_out << "print_output PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH SI\n\tLEA SI,NUMBER\n\tMOV BX,10\n\tADD SI,4\n\tCMP AX,0\n\tJNGE NEGATE\n\tPRINT:\n\tXOR DX,DX\n\tDIV BX\n\tMOV [SI],DL\n\tADD [SI],'0'\n\tDEC SI\n\tCMP AX,0\n\tJNE PRINT\n\tINC SI\n\tLEA DX,SI\n\tMOV AH,9\n\tINT 21H\n\tPOP SI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tNEGATE:\n\tPUSH AX\n\tMOV AH,2\n\tMOV DL,'-'\n\tINT 21H\n\tPOP AX\n\tNEG AX\n\tJMP PRINT\nprint_output ENDP" << endl;

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








//Intermediate Code Generation
void intermediate_code_generate(SymbolInfo* symbolInfo)
{


	if(symbolInfo->grammer == "start : program")
	{
		//code generate
		
		assembly_out <<";-------\n;\n;-------\n.MODEL SMALL\n.STACK 1000H\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n";

		for(int i=0;i<global_variable_list.size();i++)
		{	
			assembly_out<< "\t"<< global_variable_list[i]->getName() << " DW 1 DUP (0000H)\n";
		}	
		assembly_out << ".CODE\n";

		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);

	}

	//
	if(symbolInfo->grammer == "program : program unit")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[1]);
	}

	//program : unit
	if(symbolInfo->grammer == "program : unit")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}

	//unit : var_declaration
	if(symbolInfo->grammer == "unit : var_declaration")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}

	//unit : func_declaration
	if(symbolInfo->grammer == "unit : func_declaration")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}

	//unit : func_definition
	if(symbolInfo->grammer == "unit : func_definition")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}

	//func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	if(symbolInfo->grammer == "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[3]);
		
	}

	//func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON
	if(symbolInfo->grammer == "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}


	//func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
	if(symbolInfo->grammer == "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement")
	{
		paramFlag=true;

		parseTable.EnterScope();
		curr_id++;


		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		string func_name = childList[1]->getName();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[3]);

		assembly_out << func_name<< " PROC\n";

		if(func_name=="main")
		{
			assembly_out << "\tMOV AX, @DATA\n";
            assembly_out << "\tMOV DS, AX\n";
		}

		assembly_out << "\tPUSH BP\n";
        assembly_out << "\tMOV BP, SP\n";

		intermediate_code_generate(childList[5]);

		assembly_out <<  newLabel() << ":" << endl;
		
        if(func_name == "main"){
            assembly_out<< "\tMOV AX, 4CH\n";
            assembly_out << "\tINT 21H\n";
        }
        
	
        assembly_out<< "\tPOP BP\n";

        if(func_name != "main"){
            assembly_out << "\tRET " << (paramOffset-1)*2 << endl;
        }

        assembly_out << func_name << " ENDP\n";

		paramOffset = 1;
		parseTable.ExitScope();
		curr_id--;

		paramFlag=false;
		
	}


	//func_definition : type_specifier ID LPAREN RPAREN compound_statement
	if(symbolInfo->grammer == "func_definition : type_specifier ID LPAREN RPAREN compound_statement")
	{
		parseTable.EnterScope();
		curr_id++;


		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		string func_name = childList[1]->getName();

		assembly_out << func_name<< " PROC\n";

        if(func_name == "main"){
            assembly_out << "\tMOV AX, @DATA\n";
            assembly_out << "\tMOV DS, AX\n";
        }
        
		assembly_out << "\tPUSH BP" << endl;
        assembly_out << "\tMOV BP, SP" << endl;

		intermediate_code_generate(childList[0]);
        intermediate_code_generate(childList[4]);

		assembly_out << newLabel() << ":" << endl;

		assembly_out << "\tADD SP, "<< childList[4]->offset << endl;
        assembly_out << "\tPOP BP\n";

        if(func_name == "main"){
            assembly_out << "\tMOV AX, 4CH\n";
            assembly_out << "\tINT 21H\n";
        }


        if(func_name != "main"){
        	assembly_out << "\tRET\n";
        }
    	
		assembly_out << func_name<< " ENDP\n";

		if(func_name=="main")
		{
			newLine();
			println();
			assembly_out << "END main" << endl;
		}
	
		parseTable.ExitScope();
		curr_id--;

	}


	//parameter_list  : parameter_list COMMA type_specifier ID
	if(symbolInfo->grammer == "parameter_list : parameter_list COMMA type_specifier ID")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		paramOffset++;
		string name = childList[3]->getName();
		parameterlist[name]=paramOffset;

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[2]);
	
	}


	//parameter_list  : parameter_list COMMA type_specifier
	if(symbolInfo->grammer == "parameter_list : parameter_list COMMA type_specifier")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[2]);
	}

	//parameter_list  : type_specifier ID
	if(symbolInfo->grammer == "parameter_list : type_specifier ID")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		paramOffset++;

		string name = childList[1]->getName();
		parameterlist[name] = paramOffset;

	}


	//parameter_list  : type_specifier
	if(symbolInfo->grammer == "parameter_list : type_specifier")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);


	}


	//compound_statement : LCURL statements RCURL
	if(symbolInfo->grammer  == "compound_statement : LCURL statements RCURL")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		if(endLevel == "")
		{
			endLevel = newLabel();
		}

		childList[1]->level = endLevel;

		intermediate_code_generate(childList[1]);


	}


	//compound_statement : LCURL RCURL
	if(symbolInfo->grammer == "compound_statement : LCURL RCURL")
	{

	}


	//var_declaration : type_specifier declaration_list SEMICOLON
	if(symbolInfo->grammer == "var_declaration : type_specifier declaration_list SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[1]);

	}


	//type_specifier	: INT
	if(symbolInfo->grammer == "type_specifier	: INT")
	{
		var_width = 2;
	}


	//type_specifier	: VOID
	if(symbolInfo->grammer == "type_specifier	: VOID")
	{
		var_width = 0;
	}


	//declaration_list : declaration_list COMMA ID
	if(symbolInfo->grammer == "declaration_list : declaration_list COMMA ID")
	{
		
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		
		if(!childList[2]->is_global)
		{
			assembly_out << "\t" << "SUB SP, " << childList[2]->width << endl;

			string string_offset = to_string(childList[2]->offset);
			parseTable.Insert(childList[2]->getName() , string_offset);
		}

		intermediate_code_generate(childList[0]);
		
	}


	if(symbolInfo->grammer == "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		parseTable.Insert(childList[2]->getName(), childList[2]->getType());
		SymbolInfo* symbol = parseTable.Lookup(childList[2]->getName());

		intermediate_code_generate(childList[0]);

	}


	//declaration_list : ID
	if(symbolInfo->grammer == "declaration_list : ID")
	{
	
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		if(!childList[0]->is_global)
		{

			assembly_out << "\tSUB SP, " << childList[0]->width << endl;

			string string_offset = to_string(childList[0]->offset);

			parseTable.Insert(childList[0]->getName() , string_offset);
	
		}
		

	}


	if(symbolInfo->grammer == "declaration_list : ID LTHIRD CONST_INT RTHIRD")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

	}


	//statements : statement
	if(symbolInfo->grammer == "statements : statement")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		childList[0]->endLevel = newLabel();

	
		intermediate_code_generate(childList[0]);

		assembly_out << childList[0]->endLevel <<":"<< endl;//level e jhamela hoile delete dibo

	}

	//statements : statements statement
	if(symbolInfo->grammer == "statements : statements statement")
	{
		
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		childList[0]->endLevel = endLevel;
       

		intermediate_code_generate(childList[0]);
		endLevel = newLabel();
		childList[1]->endLevel = endLevel;
		intermediate_code_generate(childList[1]);

		assembly_out << endLevel <<":"<< endl;//level e jhamela hoile delete dibo

	}	


	//statement : var_declaration
	if(symbolInfo->grammer == "statement : var_declaration")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}


	//statement : expression_statement
	if(symbolInfo->grammer == "statement : expression_statement")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}	


	//statement : compound_statement
	if(symbolInfo->grammer == "statement : compound_statement")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		childList[0]->endLevel = newLabel();
		

		intermediate_code_generate(childList[0]);

	}	 


	//statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement
	if(symbolInfo->grammer == "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement")	
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[2]);

        string begin = newLabel();

        assembly_out << begin << ":\n";

        //childList[3]->condition_flag = true;
        childList[3]->trueLevel = newLabel();
        childList[3]->falseLevel = endLevel;
        childList[6]->endLevel = newLabel();

		true_level = childList[3]->trueLevel ;
		false_level =  endLevel;
        
		intermediate_code_generate(childList[3]);

        assembly_out << childList[3]->trueLevel<< ":\n";

		intermediate_code_generate(childList[6]);
		intermediate_code_generate(childList[4]);
    
        assembly_out << "\tJMP "<< begin << "\n";

	}


	//statement : IF LPAREN expression RPAREN statement
	if(symbolInfo->grammer == "statement : IF LPAREN expression RPAREN statement")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		//childList[2]->condition_flag = true;
        childList[2]->trueLevel = newLabel();
        childList[2]->falseLevel = endLevel;
        childList[4]->endLevel = endLevel;

		true_level = childList[2]->trueLevel;
		false_level = childList[2]->falseLevel ;
        
		intermediate_code_generate(childList[2]);

        assembly_out << childList[2]->trueLevel << ":\n";
        intermediate_code_generate(childList[4]);

	}

	//statement : IF LPAREN expression RPAREN statement ELSE statement
	if(symbolInfo->grammer == "statement : IF LPAREN expression RPAREN statement ELSE statement")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[2]->trueLevel = newLabel();
        childList[2]->falseLevel = newLabel();
        childList[4]->endLevel = endLevel;
        childList[6]->endLevel = endLevel;
        

		true_level = childList[2]->trueLevel;
		false_level = childList[2]->falseLevel;


		intermediate_code_generate(childList[2]);
        assembly_out << childList[2]->trueLevel<< ":\n";
        intermediate_code_generate(childList[4]);
        assembly_out << "\tJMP "<< endLevel << "\n";
        
		assembly_out << childList[2]->falseLevel<< ":\n";
		intermediate_code_generate(childList[6]);


	}


	//statement : WHILE LPAREN expression RPAREN statement
	if(symbolInfo->grammer == "statement : WHILE LPAREN expression RPAREN statement")
	{
		
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		string begin = newLabel();
        
        childList[2]->trueLevel = newLabel();
        childList[2]->falseLevel = newLabel();
        childList[4]->endLevel = symbolInfo->endLevel;
        
		true_level = childList[2]->trueLevel;
		false_level = childList[2]->falseLevel;


		assembly_out << begin << ":\n";
        intermediate_code_generate(childList[2]);

        assembly_out << childList[2]->trueLevel << ":\n";
        intermediate_code_generate(childList[4]);
		endLevel=newLabel();
        assembly_out << "\tJMP "<< begin << "\n";

		assembly_out << false_level << ":" << "\n";

	}



	//statement : PRINTLN LPAREN ID RPAREN SEMICOLON
	if(symbolInfo->grammer == "statement : PRINTLN LPAREN ID RPAREN SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		SymbolInfo* symbol = childList[2];

		SymbolInfo* checkOffset = parseTable.Lookup(childList[2]->getName());
		string off;

		if(checkOffset != nullptr)
		{
			off = checkOffset->getType();
		}

		if(symbol->is_global)
		{
            assembly_out << "\tMOV AX, "+ childList[2]->getName() +"\n";
            assembly_out << "\tCALL print_output\n";
            assembly_out << "\tCALL new_line\n";

        }
        else
		{
			assembly_out << "\tMOV AX, [BP-" << off << "]"<< endl;
			assembly_out << "\tCALL print_output" << endl;
			assembly_out << "\tCALL new_line" << endl;
        }

	}


	///statement : RETURN expression SEMICOLON
	if(symbolInfo->grammer == "statement : RETURN expression SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		returnFlag = true;
		intermediate_code_generate(childList[1]);
		returnFlag = false;
       	assembly_out << "\tJMP "<< endLevel << endl;//jump level thik kora lagte pare

	}

	//expression_statement : expression SEMICOLON
	if(symbolInfo->grammer == "expression_statement : expression SEMICOLON")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	//variable : ID
	if(symbolInfo->grammer == "variable : ID")
	{
		if(paramFlag)
		{
			vector<SymbolInfo*>childList = symbolInfo->getChildList();

			//write code
			SymbolInfo* symbol = childList[0];
			int param = parameterlist[symbol->getName()];

			if(param != NULL)
			{	
				int off = param*2;

				if(returnFlag)
				{
					assembly_out << "\tMOV [BP+" << off <<"], AX"<< endl;
				}
				else
				{
					assembly_out << "\tMOV AX, [BP+" << off << "]" << endl;
				}
				
			}
			else
			{
				SymbolInfo* checkOffset = parseTable.Lookup(symbol->getName());
				string off = "";

				if(checkOffset!= nullptr)
				{
					off = checkOffset->getType();
				}

				if(symbolInfo->is_global)
				{
					assembly_out << "\tMOV AX, "+ symbol->getName() << endl;//new add korsi
				}
				else
				{
					assembly_out << "\tMOV AX, [BP-" << off << "]" << endl;//new add korsi
				}
			}

		}
		else
		{
			vector<SymbolInfo*>childList = symbolInfo->getChildList();

			//write code
			SymbolInfo* symbol = childList[0];

			SymbolInfo* checkOffset = parseTable.Lookup(symbol->getName());
			string off = "";

			if(checkOffset!= nullptr)
			{
				off = checkOffset->getType();
			}

			if(symbolInfo->is_global)
			{
				assembly_out << "\tMOV AX, "+ symbol->getName() << endl;//new add korsi
			}
			else
			{
				assembly_out << "\tMOV AX, [BP-" << off << "]" << endl;//new add korsi
			}
		}
		

	}



	//variable : ID LTHIRD expression RTHIRD
	if(symbolInfo->grammer == "variable : ID LTHIRD expression RTHIRD")
	{
		//array
	}


	//expression : logic_expression
	if(symbolInfo->grammer == "expression : logic_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		//childList[0]->condition_flag = condition_flag;
        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	//expression : variable ASSIGNOP logic_expression
	if(symbolInfo->grammer == "expression : variable ASSIGNOP logic_expression")
	{

		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		SymbolInfo* symbol = childList[0];
		

		intermediate_code_generate(childList[2]);

		
		if(childList[0]->is_global)
		{
			assembly_out << "\tMOV " << childList[0]->getChildList()[0]->getName() << ", AX" << endl;//new add korsi
		}
		else
		{
			vector<SymbolInfo*>subChildList = childList[0]->getChildList();

			SymbolInfo* checkSymbol = subChildList[0];
			string off="";
			SymbolInfo* parseSymbolInfo = parseTable.Lookup(checkSymbol->getName());

			if(parseSymbolInfo!=nullptr)
			{
				off = parseSymbolInfo->getType();
				assembly_out << "\tMOV [BP-" << off << "], AX" << endl;//new add korsi
			}

		}

		assembly_out << "\tPUSH AX\n\tPOP AX\n";


	}


	//logic_expression : rel_expression
	if(symbolInfo->grammer == "logic_expression : rel_expression")
	{

		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	if(symbolInfo->grammer == "logic_expression : rel_expression LOGICOP rel_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

	
		SymbolInfo* symbol = childList[2];

		if(symbol->getName()=="||")
		{

		}
		else 
		{

		}

	}


	//rel_expression : simple_expression
	if(symbolInfo->grammer == "rel_expression : simple_expression")		
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	//rel_expression : simple_expression RELOP simple_expression
	if(symbolInfo->grammer == "rel_expression : simple_expression RELOP simple_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[2]);
		assembly_out << "\tMOV DX, AX" << endl;
		intermediate_code_generate(childList[0]);

		assembly_out << "\tCMP AX,DX" << endl;
		string opcode = getOpcode(childList[1]->getName());
		assembly_out << opcode << " "<< true_level << endl;
		assembly_out << "\tJMP "<< false_level << endl;

	}



	//simple_expression : term
	if(symbolInfo->grammer == "simple_expression : term")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	//simple_expression : simple_expression ADDOP term
	if(symbolInfo->grammer == "simple_expression : simple_expression ADDOP term")
	{

		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);

		assembly_out << "\tPUSH AX" << endl;

		intermediate_code_generate(childList[2]);
		assembly_out << "\tPOP CX" << endl;

		if(childList[1]->getName()=="+")
		{
			assembly_out << "\tADD AX, CX" << endl;
		}
		else if(childList[1]->getName()=="-")
		{
			assembly_out << "\tSUB CX, AX" << endl;
			assembly_out << "\tMOV AX, CX" << endl;
		}
		

	}


	//term : unary_expression
	if(symbolInfo->grammer == "term : unary_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);
	}


	//term : term MULOP unary_expression
	if(symbolInfo->grammer == "term : term MULOP unary_expression")
	{
		
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	
		assembly_out << "\tPUSH AX" << endl;
		intermediate_code_generate(childList[2]);
		assembly_out << "\tPOP CX" << endl;

		if(childList[1]->getName()=="*")
		{
			assembly_out << "\tCWD\n\tMUL CX" << endl;
			assembly_out << "\tPUSH AX\n\tPOP AX" << endl;
		}
		else if(childList[1]->getName()=="/")
		{
			assembly_out << "\tCWD\n\tDIV CX" << endl;
		}
		else if(childList[1]->getName()=="%")
		{
			assembly_out << "\tCWD" << endl;
			assembly_out << "\tDIV CX" << endl; 
		}	


	}


	//unary_expression : ADDOP unary_expression
	if(symbolInfo->grammer == "unary_expression : ADDOP unary_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[1]->trueLevel = trueLevel;
        childList[1]->falseLevel = falseLevel;
        
		intermediate_code_generate(childList[1]);

        if(childList[0]->getName() == "-")
		{
            assembly_out << "\tNEG AX\n";
        }

	}


	//unary_expression : NOT unary_expression
	if(symbolInfo->grammer == "unary_expression : NOT unary_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[1]->trueLevel = trueLevel;
        childList[1]->falseLevel = falseLevel;

		intermediate_code_generate(childList[1]);

		
		assembly_out << "\tNOT AX"<< endl;
		assembly_out << "\tPUSH AX\n\tPOP AX"<< endl;


	}


	//unary_expression : factor
	if(symbolInfo->grammer == "unary_expression : factor")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

        childList[0]->trueLevel = trueLevel;
        childList[0]->falseLevel = falseLevel;

		intermediate_code_generate(childList[0]);

	}


	//factor : variable
	if(symbolInfo->grammer == "factor : variable")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
    
	}


	//factor : ID LPAREN argument_list RPAREN
	if(symbolInfo->grammer == "factor : ID LPAREN argument_list RPAREN")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);//jhamela kortese function call korlei
		intermediate_code_generate(childList[2]);
		

        assembly_out << "\tCALL " + childList[0]->getName() +"\n";
		assembly_out << "\tPUSH AX" <<endl;
		assembly_out << "\tPOP AX" << endl;

	}


	//factor : LPAREN expression RPAREN
	if(symbolInfo->grammer == "factor : LPAREN expression RPAREN")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[1]);
	}


	//factor : CONST_INT
	if(symbolInfo->grammer == "factor : CONST_INT")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		assembly_out << "\tMOV AX, "+ childList[0]->getName() +"\n";
	}

	//factor : variable INCOP
	if(symbolInfo->grammer == "factor : variable INCOP")
	{
	
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		if(childList[0]->is_global)
		{
			assembly_out << "\tMOV AX, " << childList[0]->getChildList()[0]->getName()<< endl;//new add korsi
			assembly_out << "\tPUSH AX" << endl;
			assembly_out << "\tINC AX" << endl;	
			assembly_out << "\tMOV " << childList[0]->getChildList()[0]->getName() << ", AX" << endl;
			assembly_out << "\tPOP AX" << endl;
		}
		else
		{
			vector<SymbolInfo*>subChildList = childList[0]->getChildList();
			SymbolInfo* checkSymbol = subChildList[0];
		    string off="";

			SymbolInfo* parseSymbolInfo = parseTable.Lookup(checkSymbol->getName());

			if(parseSymbolInfo!=nullptr)
			{
				off = parseSymbolInfo->getType();
				
				assembly_out << "\tMOV AX, [BP-" << off << "]" << endl;//new add korsi
				assembly_out << "\tPUSH AX" << endl;
				assembly_out << "\tINC AX" << endl;
				assembly_out << "\tMOV [BP-" << off <<"], AX" << endl;
				assembly_out << "\tPOP AX" << endl;
			}

		}

	}


	//factor : variable DECOP
	if(symbolInfo->grammer == "factor : variable DECOP")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		if(childList[0]->is_global)
		{
			assembly_out << "\tMOV AX, "+ childList[0]->getChildList()[0]->getName()<< endl;//new add korsi
			assembly_out << "\tPUSH AX" << endl;
			assembly_out << "\tDEC AX" << endl;	
			assembly_out << "\tMOV " << childList[0]->getChildList()[0]->getName() << ", AX" << endl;
			assembly_out << "\tPOP AX" << endl;
		}
		else
		{
			vector<SymbolInfo*>subChildList = childList[0]->getChildList();
			SymbolInfo* checkSymbol = subChildList[0];
		    string off="";

			SymbolInfo* parseSymbolInfo = parseTable.Lookup(checkSymbol->getName());

			if(parseSymbolInfo!=nullptr)
			{
				off = parseSymbolInfo->getType();
				
				assembly_out << "\tMOV AX, [BP-" << off << "]" << endl;//new add korsi
				assembly_out << "\tPUSH AX" << endl;
				assembly_out << "\tDEC AX" << endl;
				assembly_out << "\tMOV [BP-" << off <<"], AX" << endl;
				assembly_out << "\tPOP AX" << endl;
			}

		}

	}


	//argument_list : arguments
	if(symbolInfo->grammer == "argument_list : arguments")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
	}

	//argument_list : empty
	if(symbolInfo->grammer == "argument_list : empty")
	{
		
	}


	if(symbolInfo->grammer == "arguments : arguments COMMA logic_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		intermediate_code_generate(childList[2]);
		assembly_out << "\tPUSH AX ;		func param\n";
		
      
	}		


	if(symbolInfo->grammer == "arguments : logic_expression")
	{
		vector<SymbolInfo*>childList = symbolInfo->getChildList();

		intermediate_code_generate(childList[0]);
		assembly_out << "\tPUSH AX ;		func param\n";
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
%left RELOP
%left LOGICOP
%left MULOP
%left ADDOP
%right NOT
%right INCOP DECOP

%nonassoc 


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		string parseTreeLine = "start : program";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;
		
		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;
		logout << "Total Lines: " << lineCount << endl;
        logout << "Total Errors: " << errorCount << endl;

		$$->addChild($1);

		printParseTree($$ , 1);

		intermediate_code_generate($$);

	}
	;



program : program unit
	{
		string parseTreeLine = "program : program unit";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

	}

	| unit 
	{
		string parseTreeLine  = "program : unit";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }
	;
	


unit : var_declaration
	{
		string parseTreeLine = "unit : var_declaration";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

	
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;

	}

    | func_declaration
	{
		string parseTreeLine = "unit : func_declaration";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }

    | func_definition
	{
		string parseTreeLine = "unit : func_definition";

		$$ = new SymbolInfo(parseTreeLine, $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

    }
    ;



//have to check function parameter redefination, return type should be store ,also function name will be stored.
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	{
		string parseTreeLine = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";

		$$ = new SymbolInfo($1->getName() + $2->getName() + "(" + $4->getName() + ")" + ";" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		
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
		string parseTreeLine = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";

		$$ = new SymbolInfo($1->getName() + $2->getName() + "(" + ")" + ";" , $1->getType());
		$$->grammer = parseTreeLine;


		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		
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
		
		string parseTreeLine = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";

		string fname = $1->getName() + $2->getName() + "(" + $4->getName() + ")" + $7->getName();
		string ftype = $1->getType();

		

		$$ = new SymbolInfo(fname , ftype);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		
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
		string parseTreeLine = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";

		$$ = new SymbolInfo( $1->getName() + $2->getName() + "(" + ")" + $6->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		
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

		symbol_details.clear_parameter_list();
		SymbolInfo_Details obj;
		function_details = obj;


    }
 	;				


new_scope:{
	
	table.EnterScope();

	//inserts all the parameter of the declared function

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
		
	
}



//have to check parameter redefination,whether type is void or not
parameter_list  : parameter_list COMMA type_specifier ID
	{
		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier ID";

		$$ = new SymbolInfo( $1->getName() + "," + $3->getName() + $4->getName() , $1->getType());//doesn't matter parameter list type cz we are inserting and have a parameter list in symbol info
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "parameter_list  : parameter_list COMMA type_specifier ID" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

		if($3->getType() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $4->getName() << "\' declared void" << endl;
			errorCount++;
		}

		else{
			
			if(symbol_details.already_in_parameterList($4->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \'" << $4->getName() << "\'" << endl;
				errorCount++;
				symbol_details.push_back_parameterList($4->getName() , $3->getType());
			}
			else{
				symbol_details.push_back_parameterList($4->getName() , $3->getType());
			}


		}

	}
		
	| parameter_list COMMA type_specifier
	{
		string parseTreeLine = "parameter_list : parameter_list COMMA type_specifier";

		$$ = new SymbolInfo($1->getName() + ","+ $3->getName() , $1->getType());//this doesn't matter
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		if($3->getType() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << "" << "\' declared void" << endl;
			errorCount++;
		}
		
		symbol_details.push_back_parameterList("",$3->getType());

    }

 	| type_specifier ID
	{
		string parseTreeLine = "parameter_list : type_specifier ID";

		$$ = new SymbolInfo($1->getName()+ $2->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "parameter_list  : type_specifier ID" << endl;

		$$->addChild($1);
		$$->addChild($2);

		if($1->getType() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $2->getName() << "\' declared void" << endl;
			errorCount++;
		}
			
		else{
			if(symbol_details.already_in_parameterList($2->getName()))
			{
				error_out << "Line# " << $1->getStartLine() << ": Redefinition of parameter \'" << $2->getName() << "\'" << endl;
				errorCount++;
				symbol_details.push_back_parameterList($2->getName() , $1->getType());
			}
			else{
				symbol_details.push_back_parameterList($2->getName() , $1->getType());
			}

		}

    }
	
	| type_specifier
	{
		string parseTreeLine = "parameter_list  : type_specifier";

		$$ = new SymbolInfo($1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		if($1->getType() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << "" << "\' declared void" << endl;
			errorCount++;
		}
			
		
		symbol_details.push_back_parameterList("" , $1->getType());


    }
 	;



//final fixed
compound_statement : LCURL new_scope statements RCURL
	{
		string parseTreeLine = "compound_statement : LCURL statements RCURL";

		$$ = new SymbolInfo( "{" + $2->getName() + "}" , $1->getType());//doesn't matter its type
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($3);
		$$->addChild($4);
		
		$$->offset = table.getOffset();

		table.PrintAllScopeTable(logout);
		table.ExitScope();

	}

 	| LCURL new_scope RCURL
	{
		string parseTreeLine = "compound_statement : LCURL RCURL";

        $$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
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
		string parseTreeLine =  "var_declaration : type_specifier declaration_list SEMICOLON";

		$$ = new SymbolInfo($1->getName() + $2->getName() + ";" , symbol_details.get_variable_type());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		$$->offset = table.getOffset();

		symbol_details.set_variable_type("");

		var_width = 0;


	}
 	;


type_specifier	: INT
	{
		string parseTreeLine = "type_specifier	: INT";

		$$ = new SymbolInfo($1->getName() , "INT");
		$$->grammer = parseTreeLine;


		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		$$->setParseTreeLine("type_specifier : INT");
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("INT");

		var_width=2;

	}

 	| FLOAT
	{
		string parseTreeLine = "type_specifier : FLOAT";

		$$ = new SymbolInfo($1->getName() , "FLOAT");
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: FLOAT" << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("FLOAT");

    }

 	| VOID
	{
		string parseTreeLine = "type_specifier : VOID";

		$$ = new SymbolInfo($1->getName() , "VOID");
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << "type_specifier	: VOID" << endl;

		$$->addChild($1);

		//sets variable type
		symbol_details.set_variable_type("VOID");

		var_width =0;

    }
 	;
 		

declaration_list : declaration_list COMMA ID
	{

		string parseTreeLine = "declaration_list : declaration_list COMMA ID";

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() , symbol_details.get_variable_type());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getEndLine());
		$$->setEndLine($3->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		//store in global variable list
		if(table.getCurrentTableId() == "1")
		{
			SymbolInfo* symbol = new SymbolInfo($3->getName() , $3->getType());
			global_variable_list.push_back(symbol);
			$3->is_global = true;
			$3->width = var_width;

		}
		else
		{
			$3->width = var_width;
			$3->offset = table.getOffset() + var_width;
			table.setOffset($3->offset);
			
		}


		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		$$->offset = table.getOffset();


		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \'" << $3->getName() << "\'" << endl;
			errorCount++;
		}
		else{
			//checks already inserted in current scope or not
			if(is_already_inserted($3->getName()))
			{
				//have to check type  of redeclaration
				if(get_id_type($3->getName()) != symbol_details.get_variable_type())
				{
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;
					errorCount++;
				}
				else
				{
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
					errorCount++;
				}
					
			}
			else
			{
				insertID_into_symbolTable($3->getName() , symbol_details.get_variable_type());
			}

		}


	}

 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
	{
		string parseTreeLine = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";

		$$ = new SymbolInfo($1->getName() + "," + $2->getName() + "[" + $5->getName() + "]" , symbol_details.get_variable_type());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($6->getEndLine());

		
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
			errorCount++;
		}
		else{
			if(is_already_inserted($3->getName()))
			{
				if(get_id_type($3->getName()) != symbol_details.get_variable_type())
				{
					errorCount++;
					error_out << "Line# " << $3->getStartLine() << ": Conflicting types for\'" << $3->getName() << "\'" << endl;

				}		
				else 
				{
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $3->getName() << "\'" << endl;
					errorCount++;
				}
					
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
		string parseTreeLine = "declaration_list : ID";

		$$ = new SymbolInfo($1->getName() , symbol_details.get_variable_type());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		//store in global variable list
		if(table.getCurrentTableId() == "1")
		{
			SymbolInfo* symbol = new SymbolInfo($1->getName() , $1->getType());
			global_variable_list.push_back(symbol);
			$1->is_global = true;
			$1->width = var_width;
		}
		else{
			$1->width = var_width;
			$1->offset = table.getOffset() + var_width;
			table.setOffset(table.getOffset() + var_width);

		}


		$$->addChild($1);
		$$->offset = table.getOffset();
		
		//inserts id into symbol table
		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
			errorCount++;
		}
		else if(symbol_details.get_variable_type() == "VOID")
		{
			error_out << "Line# " << $1->getStartLine() << ": Variable or field \'" << $1->getName() <<"\' declared void" << endl;
			errorCount++;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) != symbol_details.get_variable_type())
				{
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
					errorCount++;
				}
					
				else 
				{
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
					errorCount++;
				}
					
			}
			else
			{
				insertID_into_symbolTable($1->getName() , symbol_details.get_variable_type());
			}
		}

		

    }

 	| ID LSQUARE CONST_INT RSQUARE
	{

		string parseTreeLine = "declaration_list : ID LSQUARE CONST_INT RSQUARE";

		$$ = new SymbolInfo($1->getName() + "[" + $3->getName()+ "]" , symbol_details.get_variable_type());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);

		if(symbol_details.get_variable_type() == "")
		{
			error_out << "Line# " << $1->getStartLine() << ": Undeclared variable \' " << $1->getName() << "\'" << endl;
			errorCount++;
		}
		else{
			if(is_already_inserted($1->getName()))
			{
				if(get_id_type($1->getName()) != symbol_details.get_variable_type())
				{
					errorCount++;
					error_out << "Line# " << $1->getStartLine() << ": Conflicting types for\'" << $1->getName() << "\'" << endl;
				}
				else
				{
					error_out << "Line# " << $1->getStartLine() << ": Redefinition of variable \'" << $1->getName() << "\'" << endl;
					errorCount++;
				} 
					
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



statements : statement
	{
		string parseTreeLine = "statements : statement";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;

	}
	   
	| statements statement
	{
		string parseTreeLine = "statements : statements statement";

		$$ = new SymbolInfo( parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

		$$->offset = $2->offset;

    }
	;
	   


statement : var_declaration
	{
		string parseTreeLine = "statement : var_declaration";

		$$ = new SymbolInfo( parseTreeLine, $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;

	}
	  
	| expression_statement
	{
		string parseTreeLine = "statement : expression_statement";

		$$ = new SymbolInfo(parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;

    }

	| compound_statement
	{
		string parseTreeLine = "statement : compound_statement";

		$$ = new SymbolInfo( parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;
    }

	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		string parseTreeLine = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";

		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		
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
		string parseTreeLine = "statement : IF LPAREN expression RPAREN statement";

		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + $5->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

	
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
		string parseTreeLine = "statement : IF LPAREN expression RPAREN statement ELSE statement";

		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + $5->getName() + $6->getName() + $7->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($7->getEndLine());

		
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
		string parseTreeLine = "statement : WHILE LPAREN expression RPAREN statement";

		$$ = new SymbolInfo( $1->getName() +"(" + $3->getName() + ")" + $5->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		
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
		string parseTreeLine = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";

		$$ = new SymbolInfo( $1->getName() + "(" + $3->getName() + ")" + ";" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($5->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		SymbolInfo* checkGlobal = table.Lookup_global($3->getName());

		if(checkGlobal != nullptr)
		{
			$3->is_global = true;
		}
		else
		{
			$3->is_global = false;
		}

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
    }

	| RETURN expression SEMICOLON
	{
		string parseTreeLine = "statement : RETURN expression SEMICOLON";

		$$ = new SymbolInfo( $1->getName() + $2->getName() + ";" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
    }
	;



expression_statement 	: SEMICOLON
	{
		string parseTreeLine = "expression_statement : SEMICOLON";

		$$ = new SymbolInfo(";" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		//clear argument list
		parameter_details.clear_argument_list();
	}	

	| expression SEMICOLON
	{
		string parseTreeLine = "expression_statement : expression SEMICOLON";

		$$ = new SymbolInfo( $1->getName() + ";" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

	
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
		string parseTreeLine = "variable : ID";

		string var_name = $1->getName();
		string var_type = $1->getType();
		
		SymbolInfo* symbol_info = table.Lookup(var_name);

		if(symbol_info==nullptr)
		{
			error_out << "Line# " << $1->getStartLine() <<": Undeclared variable \'" << var_name <<"\'" << endl;
			errorCount++;

			$$ = new SymbolInfo(var_name , "undeclared");
			$$->grammer = parseTreeLine;

		}
		else
		{
			string type = symbol_info->getType();

			$$ = new SymbolInfo(var_name ,type);
			$$->grammer = parseTreeLine;

		}

	
		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		SymbolInfo* check = table.Lookup_global($1->getName());

		if(check != nullptr)
		{
			$$->is_global = true;
		}
		else
		{
			$$->is_global = false;
			$$->offset = $1->offset ;
		}

		$$->addChild($1);

	}

	| ID LSQUARE expression RSQUARE
	{
		string parseTreeLine = "variable : ID LSQUARE expression RSQUARE";

		string var_name = $1->getName();
		string var_type = $1->getType();

		SymbolInfo* symbol_info = table.Lookup(var_name);

		if(symbol_info == nullptr)
		{
			error_out << "Line# " << $1->getStartLine() <<": Undeclared variable \'" << var_name <<"\'" << endl;
			errorCount++;
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
					errorCount++;
				}

				$$ = new SymbolInfo(var_name,array_type);
				
			}
			else
			{
				error_out << "Line# " << $1->getStartLine() << ": \'" << var_name << "\' is not an array" << endl;
				errorCount++;
				$$ = new SymbolInfo(var_name,var_type);
			}

		}

		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

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
		string parseTreeLine = "expression : logic_expression";

		$$ = new SymbolInfo( parseTreeLine , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "expression 	: logic_expression" << endl;

		$$->addChild($1);

		$$->offset = $1->offset;
 	}	

	| variable ASSIGNOP logic_expression
	{
		string parseTreeLine = "expression : variable ASSIGNOP logic_expression";

		//checks  Generate error message if operands of an assignment operator are not consistent with each
		//other. Note that, the second operand of the assignment operator will be an expression that
		//may contain numbers, variables, function calls, etc.
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = operand2_type;


		if(operand1_type == "VOID" || operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;
		}
		else if(operand1_type == "INT" && operand2_type== "FLOAT")
		{
			error_out << "Line# " << lineCount << ": Warning: possible loss of data in assignment of FLOAT to INT" << endl;
			errorCount++;
			type = "INT";
		}
		else if(operand1_type == "FLOAT" && operand2_type== "FLOAT")
		{
			type = "FLOAT";
		}

		
		$$ = new SymbolInfo( $1->getName() + "=" + $3->getName() , type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "expression 	: variable ASSIGNOP logic_expression " << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }	
	;


logic_expression : rel_expression
	{
		string parseTreeLine = "logic_expression : rel_expression";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;
	}

	| rel_expression LOGICOP rel_expression
	{
		string parseTreeLine = "logic_expression : rel_expression LOGICOP rel_expression";

		//checks the result of LOGICOP should be integer
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = "INT";

		if(operand1_type == "VOID")
		{
			errorCount++;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}

		else if(operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;
		}
		else
		{
			//check error recovery
		}

		$$ = new SymbolInfo( $1->getName() + $2->getName() + $3->getName() , type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }	
	;
			

rel_expression	: simple_expression
	{
		string parseTreeLine = "rel_expression : simple_expression";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "rel_expression	: simple_expression" << endl;

		$$->addChild($1);

		$$->offset = $1->offset;

	} 

	| simple_expression RELOP simple_expression
	{
		string parseTreeLine = "rel_expression : simple_expression RELOP simple_expression";

		//checks the result of RELOP should be an integer
		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = "INT";

		if(operand1_type == "VOID")
		{
			errorCount++;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;

		}
			
		else if(operand2_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;
		}
		else
		{
			//check eeror recovery
		}

		$$ = new SymbolInfo( $1->getName() + $2->getName() + $3->getName() , type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << "rel_expression	: simple_expression RELOP simple_expression" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

		$$->offset = $1->offset;

    }
	;


simple_expression : term
	{
		string parseTreeLine = "simple_expression : term";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);

		$$->offset = $1->offset;
	}
		  
	| simple_expression ADDOP term
	{
		string parseTreeLine = "simple_expression : simple_expression ADDOP term";

		string operand1_type = $1->getType();
		string operand2_type = $3->getType();
		string type = operand1_type;

		if(operand1_type == "VOID")
		{
			errorCount++;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
		}
			
		else if(operand2_type == "VOID")
		{
			type = operand1_type;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;

		}
		else
		{
			//check error recovery
		}
		
		// Type Check

		$$ = new SymbolInfo( $1->getName() +  $2->getType() + $3->getName() , type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

    }
	;


term :	unary_expression
	{
		string parseTreeLine = "term : unary_expression";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		$$->setParseTreeLine(parseTreeLine);
		logout << "term :	unary_expression" << endl;

		$$->addChild($1);
	}
     
	|  term MULOP unary_expression
	{
		string parseTreeLine = "term : term MULOP unary_expression";

		//checks both operands for modulus int or not , disision by zero or not

		string addop_symbol = $2->getName();
		string operand1_type = $1->getType();//modify $2
		string operand2_name = $3->getName();
		string operand2_type = $3->getType();

		string type = operand2_type;

		if(operand1_type == "VOID")
		{
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;
		}
		else if(operand2_type == "VOID")
		{
			type = operand1_type;
			error_out << "Line# " << lineCount << ": Void cannot be used in expression" << endl;
			errorCount++;
		}
		else if(addop_symbol == "/")
		{
			if(operand2_name == "0")
			{
				errorCount++;
				error_out << "Line# " << lineCount << ": Warning: division by zero i=0f=1Const=0" << endl;
			}

		}
		else if(addop_symbol == "%")
		{
			if(operand2_name == "0")
			{
				error_out << "Line# " << lineCount << ": Warning: division by zero i=0f=1Const=0" << endl;
				errorCount++;
			}
			else if(operand1_type != "INT" || operand2_type!= "INT")
			{
				error_out << "Line# " << lineCount << ": Operands of modulus must be integers" << endl;
				errorCount++;
			}
				
			
			type = "INT";
		}
		else
		{
			//check error recovery
		}


		$$ = new SymbolInfo( $1->getName() + $2->getType() + $3->getName() , type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());


		$$->setParseTreeLine(parseTreeLine);
		logout << "term :	term MULOP unary_expression" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);

	}
    ;


unary_expression : ADDOP unary_expression
	{
		string parseTreeLine = "unary_expression : ADDOP unary_expression";

		$$ = new SymbolInfo( $1->getType() + $2->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
		
	} 
		 
	| NOT unary_expression
	{
		string parseTreeLine = "unary_expression : NOT unary_expression";

		$$ = new SymbolInfo( $1->getType() + $2->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($2->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);
    } 
		 
	| factor 
	{
		string parseTreeLine = "unary_expression : factor";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
    }
	;
	

factor	: variable
	{
		string parseTreeLine = "factor : variable";

		string variable_type = $1->getType();

		$$ = new SymbolInfo( $1->getName() , variable_type);
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: variable" << endl;

		$$->addChild($1);

	}

	| ID LPAREN argument_list RPAREN
	{
		string parseTreeLine = "factor : ID LPAREN argument_list RPAREN";

		string name = $1->getName();
		string type = $1->getType();

		string factor_name = $1->getName() + "("+$3->getName() + ")";

		SymbolInfo* symbol_info = table.Lookup(name);

		if(symbol_info == nullptr)
		{
			error_out << "Line# " << lineCount << ": Undeclared function \'" << name << "\'" << endl;
			errorCount++;
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
				errorCount++;
			}
			else if( argument_list.size() > parameter_list.size())
			{
				error_out << "Line# " << lineCount << ": Too many arguments to function \'"<<  name << "\'" << endl;
				errorCount++;
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
						errorCount++;
					}
				}
			}

		}
		else{

			error_out << "Line# " << lineCount << ": is not a function \' "<<  name << "\'" << endl;
			errorCount++;
			$$ = new SymbolInfo( factor_name ,"not function");
		}
			
	
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($4->getEndLine());

	
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: ID LPAREN argument_list RPAREN" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);


    }

	| LPAREN expression RPAREN
	{
		string parseTreeLine = "factor : LPAREN expression RPAREN";

		$$ = new SymbolInfo( "(" + $2->getName() + ")" , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: LPAREN expression RPAREN" << endl;

		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		
    }

	| CONST_INT
	{
		string parseTreeLine = "factor : CONST_INT";

		$$ = new SymbolInfo( $1->getName() , "INT");
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_INT " << endl;

		$$->addChild($1);

    }

	| CONST_FLOAT
	{
		string parseTreeLine = "factor : CONST_FLOAT";

		$$ = new SymbolInfo( $1->getName(),  "FLOAT");
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << "factor	: CONST_FLOAT" << endl;

		$$->addChild($1);

    }

	| variable INCOP
	{
		string parseTreeLine = "factor	: variable INCOP";

		$$ = new SymbolInfo( $1->getName() + "++" , $1->getType());
		$$->grammer = "factor : variable INCOP";

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    } 

	| variable DECOP
	{
		string parseTreeLine = "factor	: variable DECOP";

		$$ = new SymbolInfo( $1->getName()+ "--" , $1->getType());
		$$->grammer =  "factor : variable DECOP";

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		$$->addChild($2);

    }
	
	;
	

//fixed
argument_list : arguments
	{
		string parseTreeLine = "argument_list : arguments";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
		$$->setParseTreeLine(parseTreeLine);
		logout << parseTreeLine << endl;

		$$->addChild($1);
		
	}

	|
	{
		$$ = new SymbolInfo();
		$$->grammer = "argument_list : empty";
	}
	;
	
//fixed
arguments : arguments COMMA logic_expression
	{
		string parseTreeLine = "arguments : arguments COMMA logic_expression";

		$$ = new SymbolInfo( $1->getName() + "," +  $3->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($3->getEndLine());

		
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
		string parseTreeLine = "arguments : logic_expression";

		$$ = new SymbolInfo( $1->getName() , $1->getType());
		$$->grammer = parseTreeLine;

		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());

		
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
	assembly_out.open("2005110_code.asm");
	

	yyin=fp;
	yyparse();
	
	
	return 0;
}

