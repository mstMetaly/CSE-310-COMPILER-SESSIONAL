#include "ScopeTable.h"


class SymbolTable
{
    private :
        unsigned long long total_buckets;
        ScopeTable* currScopeTable;


    public:
        SymbolTable(unsigned long long n)
        {
            this->total_buckets = n;
            currScopeTable = new ScopeTable(total_buckets);
        }

        ~SymbolTable()
        {
            delete(currScopeTable);
        }

        /*Enter Scope: Create a new ScopeTable and make it current one. Also
        make the previous current table as its parentScopeTable.*/

        void EnterScope()
        {
            ScopeTable* newScopeTable = new ScopeTable(total_buckets);
            newScopeTable->setParentScope(currScopeTable);
            currScopeTable = newScopeTable;

            if(currScopeTable->getParentScope() != nullptr)
            {
                string p_currentId = currScopeTable->getParentScope()->getCurrentId();
                int p_totalChild = currScopeTable->getParentScope()->getTotalChild();
                p_totalChild++;
                currScopeTable->getParentScope()->setChildScope(p_totalChild);

                string currentId = p_currentId + "." + to_string(p_totalChild);

                currScopeTable->setCurrentId(currentId);
            }
            else{
               int child =  currScopeTable->getTotalChild();
               child++;
               currScopeTable->setChildScope(child);
            }
        
        }
        
        /*❏ Exit Scope: Remove the current ScopeTable.*/
        bool ExitScope()
        {
            if(currScopeTable->getParentScope() == nullptr)
                return false;
            else{
                ScopeTable* tempScope = currScopeTable;
                currScopeTable = currScopeTable->getParentScope();
                //delete(tempScope);
                return true;
            }

            return false;
        }

        /*Insert: Insert a symbol in current ScopeTable. Return true for
        successful insertion and false otherwise.*/
        bool Insert(string name , string type)
        {
            if(currScopeTable != nullptr)
            {
                SymbolInfo* alreadyExistPtr = currScopeTable->Lookup(name);

                if(alreadyExistPtr != nullptr)
                {
                    return false;
                }

                return currScopeTable->Insert(name , type);
            }
                
        }

        bool Remove(string name)
        {
            if(currScopeTable!=nullptr)
            {
                SymbolInfo* exitPtr = currScopeTable->Lookup(name);

                if(exitPtr != nullptr)
                return currScopeTable->Delete(name);
                else
                return false;
            }
        }

        /* Look up: Look up a symbol in the ScopeTable. At first search in the
        current ScopeTable, if not found then search in its parent ScopeTable
        and so on. Return a pointer to the SymbolInfo object representing the
        searched symbol.*/

        SymbolInfo* Lookup(string name)
        {
            //cout << "In symbol table lookup"<< endl;

            SymbolInfo* getPtr = currScopeTable->Lookup(name);

            if(getPtr != nullptr)
                return getPtr;
            
            ScopeTable* current = currScopeTable->getParentScope();

            while(current != nullptr)
            {
                 if(current->Lookup(name) != nullptr)
                    return current->Lookup(name);
                
                current = current->getParentScope(); 
            }

            return nullptr;

        }

        /*Print Current ScopeTable: Print the current ScopeTable.*/

        void PrintCurrentScopeTable(ofstream& outfile)
        {
            if(currScopeTable != nullptr)
                currScopeTable->Print(outfile);
        }

        /*Print All ScopeTable: Print all the ScopeTables currently in the
        SymbolTable.*/

        void PrintAllScopeTable(ofstream& outfile)
        {
            ScopeTable* current =  currScopeTable;

            while (current != nullptr)
            {
                current->Print(outfile);
                current = current->getParentScope();
            }
            
        }

        void findIndex(string name , long long &indexNo , long long& subIndexNo)
        {
            currScopeTable->findIndex(name , indexNo , subIndexNo);
        }

        string getCurrentTableId()
        {
            return currScopeTable->getCurrentId();
        }

};

