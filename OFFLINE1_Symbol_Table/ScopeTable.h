#include "SymbolInfo.h"

// ScopeTable implements a hash table

class ScopeTable
{
    private:
        unsigned long long total_buckets ;
        SymbolInfo** arrayScope;
        ScopeTable* parentScope;

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
        this->total_buckets  = n;
        this->parentScope = nullptr;

        arrayScope = new SymbolInfo*[n];
        
        for(unsigned long long i=0 ; i < n ; i++)
        {
            arrayScope[i] = nullptr;
        }

    }


    ~ScopeTable()
    {
        for(unsigned long long i = 0; i < total_buckets ; i++)
        {
            if(arrayScope[i]!= nullptr)
            {
                SymbolInfo* current = arrayScope[i];
                SymbolInfo* next = current->getNextSymbolInfo();

                 while(next!= nullptr)
                {
                    SymbolInfo* temp = next;
                    next = next->getNextSymbolInfo();
                    delete(temp);
                }

                delete(current);

            }  

        }

        delete(arrayScope);
       
    }




    ScopeTable* getParentScope()
    {
        return this->parentScope;
    }

    void setParentScope(ScopeTable* parentScope)
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


     //uint32_t sdbmhash(char* str)
    uint32_t sdbmhash(string strName){
    //static unsigned long long sdbmhash(const string strName){
        const unsigned char *str = reinterpret_cast<const unsigned char*>(strName.c_str());
        {
            //unsigned long long hash = 0;
            uint32_t hash = 0;

            int c;

            while (c = *str++){
            hash = c + (hash << 6) + (hash << 16) - hash;
            }

            return hash;
        }
    }



    unsigned long long hashFunction(string name)
    {
        return sdbmhash(name)%total_buckets;
    }



    /*Insert: Insert into symbol table if already not inserted in this scope table.
    Return type of this function should be boolean indicating whether insertion
    is successful or not.*/

    bool Insert(string name , string type)
    {

        unsigned long long index =  hashFunction(name);
        //unsigned long long subIndex = 1;
        
        if(arrayScope[index] == nullptr)
        {
            arrayScope[index] = new SymbolInfo(name , type);
            //cout << "\t" << "Inserted  at position <"<<index << ","<< subIndex << "> of ScopeTable# 1.1"<< endl;
            return true;
        }
        else{

            SymbolInfo* current = arrayScope[index];
            SymbolInfo * prev = current;

            //++subIndex;

            while(current->getNextSymbolInfo()!= nullptr)
            {
                current = current->getNextSymbolInfo();
               // ++subIndex; 
            } 

            current->setNextSymbolInfo(new SymbolInfo(name , type));
           // cout << "\t" << "Inserted  at position <"<<index << ","<< subIndex << "> of ScopeTable# 1.1"<< endl;

            return true;
        }

        return false;

    }



    /*
         Look up: Search the hash table for a particular symbol. Return a
        SymbolInfo pointer.
    */
    
    SymbolInfo* Lookup(string name)
    {
        SymbolInfo* getPtr = nullptr;

        //cout << "in look up"<< endl;
        
        for(unsigned long long i = 0; i< total_buckets ; i++)
        {
            unsigned long long subIndex = 1;

            if(arrayScope[i] == nullptr)
                continue;

            else if(arrayScope[i]->getName() == name)
            {
                //cout <<"\t"<< name << " found at position <" << i << ", 1> of ScopeTable# 1"<< endl;
                getPtr = arrayScope[i];

                break;
            }

            else{
                ++subIndex;

                if(arrayScope[i]->getNextSymbolInfo() != nullptr)
                {
                    SymbolInfo* current = arrayScope[i]->getNextSymbolInfo();

                    while(current != nullptr)
                    {
                        if(current->getName() == name)
                        {
                            //cout <<"\t"<< name << " found at position <" << i << ", " << subIndex << "> of ScopeTable 1"<< endl;
                    
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
    bool Delete(string name){

        /*SymbolInfo* symbolInfoPtr =  Lookup(name);

        if(symbolInfoPtr == nullptr)
        {
            return false;
        }*/

        for(unsigned long long i = 0 ; i < total_buckets ; i++)
        {
            SymbolInfo* current = arrayScope[i];
            SymbolInfo* prev = current;

            if(current == nullptr)
                continue;

            else if(current->getName() == name)
            {
                arrayScope[i] = current->getNextSymbolInfo();
                delete(current);
                return true;
            }

            else if(current->getNextSymbolInfo() != nullptr)
            {
                while(current->getNextSymbolInfo() != nullptr)
                {
                    if(current->getName() == name)
                    {
                        prev->setNextSymbolInfo(current->getNextSymbolInfo());
                        delete(current);
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
        //scopeTable Number
        cout << "\tScopeTable# 1.1"<< endl;
        outfile << "\tScopeTable# 1.1"<< endl;

        for(unsigned long long i = 0 ; i < total_buckets ; i++)
        {
            SymbolInfo* current = arrayScope[i];
            SymbolInfo* next;

            if(current == nullptr)
            {
                cout <<"\t"<<  i << endl;
                outfile <<"\t"<<  i << endl;
            }
            else{
                if(current->getNextSymbolInfo() == nullptr)
                {
                    cout <<"\t"<< i << " --> (" << current->getName() << "," << current->getType() << ")" << endl;
                    outfile <<"\t"<< i << " --> (" << current->getName() << "," << current->getType() << ")" << endl;
                }
                
                else if(current->getNextSymbolInfo()!= nullptr)
                {
                    cout <<"\t"<< i << " --> (" << current->getName() << "," << current->getType() << ")";
                    outfile <<"\t"<< i << " --> (" << current->getName() << "," << current->getType() << ")";
                    next = current->getNextSymbolInfo();

                    while(next != nullptr)
                    {
                        cout << " --> (" << next->getName() << "," << next->getType() << ")" ;
                        outfile << " --> (" << next->getName() << "," << next->getType() << ")" ;
                        next = next->getNextSymbolInfo();
                    }
                    cout << endl;
                }
            }
        }
    }


    void findIndex(string name ,long long &indexNo , long long &subIndexNo)
    {
        
        for(unsigned long long i = 0; i< total_buckets ; i++)
        {
            unsigned long long subIndex = 1;

            if(arrayScope[i] == nullptr)
                continue;

            else if(arrayScope[i]->getName() == name)
            {
                //cout <<"\t"<< name << " found at position <" << i << ", 1> of ScopeTable# 1"<< endl;
                indexNo = i;
                subIndexNo =  subIndex;
                break;
            }

            else{
                ++subIndex;

                if(arrayScope[i]->getNextSymbolInfo() != nullptr)
                {
                    SymbolInfo* current = arrayScope[i]->getNextSymbolInfo();

                    while(current != nullptr)
                    {
                        if(current->getName() == name)
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
