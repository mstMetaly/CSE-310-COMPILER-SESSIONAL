#include <iostream>
#include <string>

using namespace std;

class SymbolInfo
{

private:
    string name;
    string type;
    SymbolInfo *nextSymbolInfo;

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
};
