#include<bits/stdc++.h>
#include <iostream>
#include <string>

using namespace std;

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
    SymbolInfo()
    {
        name = "";
        type = "";
        nextSymbolInfo = nullptr;
    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        nextSymbolInfo = nullptr;
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
        // scopeTable Number
        outfile << "\tScopeTable# " << current_id << endl;

        for (unsigned long long i = 0; i < total_buckets; i++)
        {
            SymbolInfo *current = arrayScope[i];
            SymbolInfo *next;

            if (current == nullptr)
            {
                outfile << "\t" << i + 1 << endl;
            }
            else
            {
                if (current->getNextSymbolInfo() == nullptr)
                {
                    outfile << "\t" << i + 1 << " --> (" << current->getName() << "," << current->getType() << ")" << endl;
                }

                else if (current->getNextSymbolInfo() != nullptr)
                {
                    outfile << "\t" << i + 1 << " --> (" << current->getName() << "," << current->getType() << ")";
                    next = current->getNextSymbolInfo();

                    while (next != nullptr)
                    {
                        outfile << " --> (" << next->getName() << "," << next->getType() << ")";
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
