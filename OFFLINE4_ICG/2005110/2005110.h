#include<bits/stdc++.h>
#include <iostream>
#include <string>

using namespace std;


class SymbolInfo_Details
{
private:
    string name;
    string type;
    string func_return_type;
    vector<SymbolInfo_Details>parameter_list;
    vector<SymbolInfo_Details>argument_list;
    bool isArray;
    bool isFunction;
    string var_type;
    bool isDeclared;
    bool isDefined;
    bool is_error_func;
    bool is_id;

public:
    SymbolInfo_Details()
    {
        name = "";
        type = "";
        func_return_type = "";
        isArray = false;
        isFunction = false;
        var_type = "";
        isDeclared = false;
        isDefined = false;
        is_error_func = false;
        is_id = false;

    }

    SymbolInfo_Details(string name , string type)
    {
        this->name = name;
        this->type = type;
        isArray = false;
        isFunction = false;
        var_type = "";
        isDeclared = false;
        isDefined = false;
        is_error_func = false;
        is_id = false;
    }

    string getName()
    {
        return this->name;
    }

    void setName(string name)
    {
        this->name = name;
    }

    string getType()
    {
        return this->type;
    }

    void setType(string type)
    {
        this->type = type;
    }

    string getFuncType()
    {
        return func_return_type;
    }

    void set_func_ret_type(string ret_type)
    {
        this->func_return_type = ret_type;
    }

    int get_parameterList_size()
    {
        return parameter_list.size();
    }

    void set_is_array(bool val)
    {
        this->isArray = val;
    }

    bool check_is_array()
    {
        return isArray;
    }

    bool check_is_function()
    {
        return isFunction;
    }

    void set_is_function(bool val)
    {
        this->isFunction = val;
    }

    bool get_is_declared()
    {
        return isDeclared;
    }

    void set_is_declared(bool val)
    {
        this->isDeclared = val;
    }

    bool get_is_defined()
    {
        return isDefined;
    }

    void set_is_defined(bool val)
    {
        this->isDefined = val;
    }

    bool get_is_error_function()
    {
        return this->is_error_func;
    }

    void set_is_error_function(bool val)
    {
        this->is_error_func = val;
    }

    bool get_is_id()
    {
        return is_id;
    }

    void set_is_id(bool val)
    {
        this->is_id = val;
    }

    void push_back_parameterList(string name ,string type)
    {
        SymbolInfo_Details symbol_details(name , type);
        this->parameter_list.push_back(symbol_details);
    }

    bool already_in_parameterList(string name)
    {
        for(int i = 0; i < parameter_list.size() ; i++)
        {
            SymbolInfo_Details symbol_details = parameter_list[i];

            if(name == symbol_details.getName())
                return true;
        }

        return false;
    }

    vector<SymbolInfo_Details>get_parameter_list()
    {
        return parameter_list;
    }

    void push_back_argumentList(string name ,string type)
    {
        SymbolInfo_Details symbol_details(name , type);
        this->argument_list.push_back(symbol_details);
    }

    vector<SymbolInfo_Details>get_argument_list()
    {
        return argument_list;
    }

    void clear_argument_list()
    {
        argument_list.clear();
    }

    void clear_parameter_list()
    {
        parameter_list.clear();
    }

    void set_variable_type(string var_type)
    {
        this->var_type = var_type;
    }

    string get_variable_type()
    {
        return this->var_type;
    }


};


class SymbolInfo
{

private:
    string name;
    string type;
    SymbolInfo *nextSymbolInfo;

    int startLine;
    int endLine;
    bool isLeaf;
    string parseTreeLine;
    vector<SymbolInfo*> childList;

    

public:
    string grammer;
    int width;
    int offset;
    int scopeCount;
    bool is_global;
    int varCount;
    string trueLevel;
    string falseLevel;
    string endLevel;
    bool condition_flag;
    string level;
    string nextLevel;
    SymbolInfo_Details symbolInfo_details;

    SymbolInfo()
    {
        name = "";
        type = "";
        nextSymbolInfo = nullptr;
        SymbolInfo_Details obj;
        symbolInfo_details = obj;
        offset = 0;
        varCount = 0;
    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        nextSymbolInfo = nullptr;

        SymbolInfo_Details obj;
        symbolInfo_details = obj;
    }

    SymbolInfo(const SymbolInfo &obj)
    {
        this->name = obj.getName();
        this->type = obj.getType();

        if (obj.getNextSymbolInfo() != nullptr)
        {
            this->nextSymbolInfo = new SymbolInfo(*obj.nextSymbolInfo);
        }
        else
        {
            this->nextSymbolInfo = nullptr;
        }
    }

    ~SymbolInfo()
    {
    }

    string getName() const
    {
        return this->name;
    }

    string getType() const
    {
        return this->type;
    }

    SymbolInfo *getNextSymbolInfo() const
    {
        return this->nextSymbolInfo;
    }

    void setNextSymbolInfo(SymbolInfo *next)
    {
        this->nextSymbolInfo = next;
    }

    int getStartLine()
    {
        return startLine;
    }

    void setStartLine(int startLine)
    {
        this->startLine = startLine;
    }

    int getEndLine()
    {
        return endLine;
    }

    void setEndLine(int endLine)
    {
        this->endLine = endLine;
    }

    bool getIsLeaf()
    {
        return isLeaf;
    }

    void setIsLeaf(bool isLeaf)
    {
        this->isLeaf = isLeaf;
    }


    string getParseTreeLine()
    {
        return this->parseTreeLine;
    }

    void setParseTreeLine(string parseTreeLine)
    {
        this->parseTreeLine = parseTreeLine;
    }

    vector<SymbolInfo*> getChildList()
    {
        return this->childList;
    }

    void addChild(SymbolInfo* symbolInfo)
    {
        childList.push_back(symbolInfo);
    }


};



//ScopeTable


// ScopeTable implements a hash table

class ScopeTable
{
private:
    unsigned long long total_buckets;
    SymbolInfo **arrayScope;
    ScopeTable *parentScope;

    string current_id;
    unsigned long long totalChildScope;
    

public:
    int offset = 0;
    ScopeTable()
    {
        totalChildScope = 0;
        current_id = "1";
        arrayScope = nullptr;
        parentScope = nullptr;
    }

    ScopeTable(unsigned long long n)
    {
        totalChildScope = 0;
        current_id = "1";
        this->total_buckets = n;
        this->parentScope = nullptr;

        arrayScope = new SymbolInfo *[n];

        for (unsigned long long i = 0; i < n; i++)
        {
            arrayScope[i] = nullptr;
        }
    }

    ~ScopeTable()
    {
        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            if (arrayScope[i] != nullptr)
            {
                SymbolInfo *current = arrayScope[i];
                SymbolInfo *next = current->getNextSymbolInfo();

                while (next != nullptr)
                {
                    SymbolInfo *temp = next;
                    next = next->getNextSymbolInfo();
                    delete (temp);
                }

                delete (current);
            }
        }

        delete (arrayScope);
    }

    ScopeTable *getParentScope()
    {
        return this->parentScope;
    }

    void setParentScope(ScopeTable *parentScope)
    {
        this->parentScope = parentScope;
    }

    int getTotalChild()
    {
        return this->totalChildScope;
    }

    void setChildScope(int total)
    {
        this->totalChildScope = total;
    }

    string getCurrentId()
    {
        return this->current_id;
    }

    void setCurrentId(string currentId)
    {
        this->current_id = currentId;
    }

    unsigned long long sdbmhash(string str)
    {

        unsigned long long hash = 0;

        for (int i = 0; i < str.length(); i++)
        {
            hash = str[i] + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }

    unsigned long long hashFunction(string name)
    {
        unsigned long long hashVal = sdbmhash(name) % total_buckets;
        return hashVal;
    }

    /*Insert: Insert into symbol table if already not inserted in this scope table.
    Return type of this function should be boolean indicating whether insertion
    is successful or not.*/

    bool Insert(string name, string type)
    {

        unsigned long long index = hashFunction(name);

        if (arrayScope[index] == nullptr)
        {
            arrayScope[index] = new SymbolInfo(name, type);
            return true;
        }
        else
        {

            SymbolInfo *current = arrayScope[index];
            SymbolInfo *prev = current;

            while (current->getNextSymbolInfo() != nullptr)
            {
                current = current->getNextSymbolInfo();
            }

            current->setNextSymbolInfo(new SymbolInfo(name, type));
            return true;
        }

        return false;
    }

    /*
         Look up: Search the hash table for a particular symbol. Return a
        SymbolInfo pointer.
    */

    SymbolInfo *Lookup(string name)
    {
        SymbolInfo *getPtr = nullptr;

        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            unsigned long long subIndex = 1;

            if (arrayScope[i] == nullptr)
                continue;

            else if (arrayScope[i]->getName() == name)
            {
                getPtr = arrayScope[i];
                break;
            }

            else
            {
                ++subIndex;

                if (arrayScope[i]->getNextSymbolInfo() != nullptr)
                {
                    SymbolInfo *current = arrayScope[i]->getNextSymbolInfo();

                    while (current != nullptr)
                    {
                        if (current->getName() == name)
                        {
                            getPtr = current;
                            break;
                        }
                        ++subIndex;
                        current = current->getNextSymbolInfo();
                    }
                }
            }
        }

        return getPtr;
    }

    /*
        Delete: Delete an entry from the symbol table. Return true in case of
        successful deletion and false otherwise.
    */
    bool Delete(string name)
    {

        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            SymbolInfo *current = arrayScope[i];
            SymbolInfo *prev = current;

            if (current == nullptr)
                continue;

            else if (current->getName() == name)
            {
                arrayScope[i] = current->getNextSymbolInfo();
                delete (current);
                return true;
            }

            else if (current->getNextSymbolInfo() != nullptr)
            {
                while (current != nullptr)
                {
                    if (current->getName() == name)
                    {
                        prev->setNextSymbolInfo(current->getNextSymbolInfo());
                        delete (current);
                        return true;
                    }

                    prev = current;
                    current = current->getNextSymbolInfo();
                }
            }
        }

        return false;
    }

    /*Print: Print the scope table in the console.*/
    void Print(ofstream& outfile)
    {
        SymbolInfo_Details details_obj ;
        // scopeTable Number
        int tableIDSum = sumOfDotSeparatedNumbers(current_id);
        outfile << "\tScopeTable# " << tableIDSum << endl;

        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            SymbolInfo *current = arrayScope[i];
            SymbolInfo *next;

            if (current == nullptr)
            {
               // outfile << "\t" << i + 1 << endl;
            }
            else
            {
                if (current->getNextSymbolInfo() == nullptr)
                {
                    if(current->getType()=="FUNCTION")
                    {
                        SymbolInfo_Details details_obj = current->symbolInfo_details;
                        string ret_type = details_obj.getFuncType();
                        outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << current->getType() << ","<< ret_type << ">" << endl;
                    }
                    else
                    {
                        details_obj = current->symbolInfo_details;
                        if(details_obj.check_is_array())
                        {
                             outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << "ARRAY" << ">" << endl;
                        }
                        else
                        {
                             outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << current->getType() << ">" << endl;
                        }
                       
                    }
                   
                }

                else if (current->getNextSymbolInfo() != nullptr)
                {
                    if(current->getType() == "FUNCTION")
                    {
                        SymbolInfo_Details details_obj = current->symbolInfo_details;
                        string ret_type = details_obj.getFuncType();
                        outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << current->getType() << "," << ret_type << ">";
                    }
                    else
                    {
                        details_obj = current->symbolInfo_details;
                        if(details_obj.check_is_array())
                        {
                            outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << "ARRAY" << ">";
                        }
                        else
                        {
                            outfile << "\t" << i + 1 << "--> <" << current->getName() << "," << current->getType() << ">";
                        }
                       
                    }
                   
                    next = current->getNextSymbolInfo();

                    while (next != nullptr)
                    {
                        if(next->getType()=="FUNCTION")
                        {
                            SymbolInfo_Details details_obj = next->symbolInfo_details;
                            string ret_type = details_obj.getFuncType();
                            outfile << " <" << next->getName() << "," << next->getType() << ","<< ret_type << ">";
                        }
                        else
                        {
                            details_obj = next->symbolInfo_details;
                            if(details_obj.check_is_array())
                            {
                                outfile << " <" << next->getName() << "," << "ARRAY" << ">";
                            }
                            else
                            {
                                outfile << " <" << next->getName() << "," << next->getType() << ">";
                            }
                           
                        }
                       
                        next = next->getNextSymbolInfo();
                    }
                    cout << endl;
                    outfile << endl;
                }
            }
        }
    }

    void findIndex(string name, long long &indexNo, long long &subIndexNo)
    {

        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            unsigned long long subIndex = 1;

            if (arrayScope[i] == nullptr)
                continue;

            else if (arrayScope[i]->getName() == name)
            {
                indexNo = i;
                subIndexNo = subIndex;
                break;
            }

            else
            {
                ++subIndex;

                if (arrayScope[i]->getNextSymbolInfo() != nullptr)
                {
                    SymbolInfo *current = arrayScope[i]->getNextSymbolInfo();

                    while (current != nullptr)
                    {
                        if (current->getName() == name)
                        {
                            indexNo = i;
                            subIndexNo = subIndex;
                            break;
                        }
                        ++subIndex;
                        current = current->getNextSymbolInfo();
                    }
                }
            }
        }
    }


    //get the sum of table id
    int sumOfDotSeparatedNumbers(const string& inputString) {
    stringstream ss(inputString);
    string token;
    vector<int> numbers;

    while (getline(ss, token, '.')) {
            int number = stod(token);
            numbers.push_back(number);
    }

    int sum = 0;
    for (const auto& number : numbers) {
        sum += number;
    }

    return sum;
}

};



//SymbolTable

class SymbolTable
{
private:
    unsigned long long total_buckets;
    ScopeTable *currScopeTable;

public:

    SymbolTable(unsigned long long n)
    {
        this->total_buckets = n;
        currScopeTable = new ScopeTable(total_buckets);
    }

    ~SymbolTable()
    {
        delete (currScopeTable);
    }

    /*Enter Scope: Create a new ScopeTable and make it current one. Also
    make the previous current table as its parentScopeTable.*/
    int getOffset()
    {
        return currScopeTable->offset;
    }

    void setOffset(int offset)
    {
        currScopeTable->offset = offset;
    }

    void EnterScope()
    {
        ScopeTable *newScopeTable = new ScopeTable(total_buckets);
        newScopeTable->setParentScope(currScopeTable);
        currScopeTable = newScopeTable;
        

        if (currScopeTable->getParentScope() != nullptr)
        {
            string p_currentId = currScopeTable->getParentScope()->getCurrentId();
            int p_totalChild = currScopeTable->getParentScope()->getTotalChild();
            p_totalChild++;
            currScopeTable->getParentScope()->setChildScope(p_totalChild);

            string currentId = p_currentId + "." + to_string(p_totalChild);

            currScopeTable->setCurrentId(currentId);
        }
        else
        {
            int child = currScopeTable->getTotalChild();
            child++;
            currScopeTable->setChildScope(child);
        }
    }

    /*❏ Exit Scope: Remove the current ScopeTable.*/
    bool ExitScope()
    {
        if (currScopeTable->getParentScope() == nullptr)
            return false;
        else
        {
            ScopeTable *tempScope = currScopeTable;
            currScopeTable = currScopeTable->getParentScope();
            delete (tempScope);
            return true;
        }

        return false;
    }

    /*Insert: Insert a symbol in current ScopeTable. Return true for
    successful insertion and false otherwise.*/
    bool Insert(string name, string type)
    {
        if (currScopeTable != nullptr)
        {
            SymbolInfo *alreadyExistPtr = currScopeTable->Lookup(name);

            if (alreadyExistPtr != nullptr)
            {
                return false;
            }

            return currScopeTable->Insert(name, type);
        }
        return false;
    }

    bool Remove(string name)
    {
        if (currScopeTable != nullptr)
        {
            SymbolInfo *exitPtr = nullptr;

            exitPtr = currScopeTable->Lookup(name);

            if (exitPtr != nullptr)
            {
                return currScopeTable->Delete(name);
            }
            else
                return false;
        }

        return false;
    }

    /* Look up: Look up a symbol in the ScopeTable. At first search in the
    current ScopeTable, if not found then search in its parent ScopeTable
    and so on. Return a pointer to the SymbolInfo object representing the
    searched symbol.*/

    SymbolInfo *Lookup(string name)
    {
        SymbolInfo *getPtr = nullptr;
        ScopeTable *current = currScopeTable;

        while (current != nullptr)
        {
            getPtr = current->Lookup(name);
            if (getPtr != nullptr)
                break;
            current = current->getParentScope();
        }
        return getPtr;
    }

    SymbolInfo* Lookup_current(string name)
    {
        SymbolInfo *getPtr = nullptr;

        if(currScopeTable==nullptr)
        {
            return nullptr;
        }
       
        getPtr = currScopeTable->Lookup(name);
        return getPtr;
        
    }


    SymbolInfo* Lookup_global(string name)
    {
        ScopeTable *global_scope = currScopeTable;

        if(currScopeTable == nullptr)
            return nullptr;

        while (global_scope->getParentScope() != nullptr)
        {
            global_scope = global_scope->getParentScope();
        }

        return global_scope->Lookup(name);
    }


    /*Print Current ScopeTable: Print the current ScopeTable.*/

    void PrintCurrentScopeTable(ofstream &outfile)
    {
        if (currScopeTable != nullptr)
            currScopeTable->Print(outfile);
    }

    /*Print All ScopeTable: Print all the ScopeTables currently in the
    SymbolTable.*/

    void PrintAllScopeTable(ofstream &outfile)
    {
        ScopeTable *current = currScopeTable;

        while (current != nullptr)
        {
            current->Print(outfile);
            current = current->getParentScope();
        }
    }

    void Quilt(ofstream &outfile)
    {
        ScopeTable *current = currScopeTable;
        while (current != nullptr)
        {
            ScopeTable *tempScope = current;
            cout << "\tScopeTable# " << current->getCurrentId() << " deleted" << endl;
            //outfile << "\tScopeTable# " << current->getCurrentId() << " deleted" << endl;
            delete (tempScope);

            current = current->getParentScope();
        }
    }

    void findIndex(string name, long long &indexNo, long long &subIndexNo)
    {
        currScopeTable->findIndex(name, indexNo, subIndexNo);
    }

    void findIndexFromAllTable(string name, long long &indexNo, long long &subIndexNo, string &tableId)
    {
        SymbolInfo *getPtr = nullptr;
        ScopeTable *current = currScopeTable;

        while (current != nullptr)
        {
            getPtr = current->Lookup(name);
            current->findIndex(name, indexNo, subIndexNo);
            tableId = current->getCurrentId();
            if (getPtr != nullptr)
                break;
            current = current->getParentScope();
        }
    }

    string getCurrentTableId()
    {
        return currScopeTable->getCurrentId();
    }
};


