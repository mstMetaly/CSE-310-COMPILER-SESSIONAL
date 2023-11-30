#include <iostream>
#include <string>

using namespace std;

class SymbolInfo
{

private:
    string name;
    string type;
    SymbolInfo* nextSymbolInfo;

public:
    

    SymbolInfo()
    {
        //cout << "In symbolinfo constructor"<< endl;
        name = "";
        type = "";
        nextSymbolInfo = nullptr;
    }


    SymbolInfo(string name, string type)
    {
       // cout << "In symbolinfo parameter constructor"<< endl;
        this->name = name;
        this->type = type;
        nextSymbolInfo = nullptr;
    }

    
    SymbolInfo(const SymbolInfo &obj)
    {
        //cout << "In symbol info copy constructor!"<< endl;
        this->name = obj.getName();
        this->type = obj.getType();
        
        if (obj.getNextSymbolInfo() != nullptr) {
        this->nextSymbolInfo = new SymbolInfo(*obj.nextSymbolInfo);
        } 
        else
        {
        this->nextSymbolInfo = nullptr;
        }

    }



    ~SymbolInfo()
    {
        //cout << "In symbolinfo destructor"<< endl;
       // delete (nextSymbolInfo);
    }



    string getName() const
    {
        return this->name;
    }



    string getType() const
    {
        return this->type;
    }



    SymbolInfo* getNextSymbolInfo() const
    {
        return this->nextSymbolInfo;
    }



    void setNextSymbolInfo(SymbolInfo* next)
    {
        this->nextSymbolInfo = next;
    }

};



