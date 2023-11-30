#include <iostream>
#include <fstream>
#include <sstream>
#include <iterator>
#include "SymbolTable.h"

using namespace std;

int main()
{
    ifstream infile;
    ofstream outfile;

    infile.open("input.txt");
    outfile.open("output.txt");

    if (!infile.is_open())
    {
        cerr << "Error opening the file!" << endl;
        return 1;
    }

    unsigned long long n;
    infile >> n;
    string line;
    int count = 0;

    SymbolTable *symbolTable = new SymbolTable(n);
    cout << "\t"<< "ScopeTable# 1 created" << endl;
    outfile << "\t"<< "ScopeTable# 1 created" << endl;

    while (getline(infile, line))
    {
        cout << "Cmd " << count << ": " << line << endl;
        outfile << "Cmd " << count << ": " << line << endl;

        count++;

        istringstream iss(line);
        string order;

        // Extract the first word from the line
        if (iss >> order)
        {
            if (order == "I")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 2)
                {
                    cout << "\tWrong number of arugments for the command " << order << endl;
                    outfile << "\tWrong number of arugments for the command " << order << endl;
                }
                else
                {

                    iss.clear();
                    iss.seekg(0);
                    iss >> order;

                    string symbolName, symbolType;
                    string tableId = symbolTable->getCurrentTableId();

                    if (iss >> symbolName >> symbolType)
                    {
                        bool retVal = symbolTable->Insert(symbolName, symbolType);

                        if (retVal)
                        {
                            // get the actual index and subIndex
                            long long indexNo = -1, subIndexNo = -1;
                            symbolTable->findIndex(symbolName, indexNo, subIndexNo);

                            cout << "\t"
                                 << "Inserted  at position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                            outfile << "\t"
                                    << "Inserted  at position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                        }
                        else
                        {
                            cout << "\t"
                                 << "'" << symbolName << "'"
                                 << " already exists in the current ScopeTable# " << tableId << endl;
                            outfile << "\t"
                                    << "'" << symbolName << "'"
                                    << " already exists in the current ScopeTable# " << tableId << endl;
                        }
                    }
                }
            }

            else if (order == "L")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 1)
                {
                    cout << "\t"
                         << "Wrong number of arugments for the command " << order << endl;
                    outfile << "\t"
                            << "Wrong number of arugments for the command " << order << endl;
                }
                else
                {
                    iss.clear();
                    iss.seekg(0);
                    iss >> order;

                    string symbolName;

                    if (iss >> symbolName)
                    {
                        SymbolInfo *retVal = symbolTable->Lookup(symbolName);

                        if (retVal != nullptr)
                        {
                            // get the index where found
                            string tableId = symbolTable->getCurrentTableId();

                            long long indexNo, subIndexNo;

                            symbolTable->findIndex(symbolName, indexNo, subIndexNo);

                            cout << "\t"
                                 << "'" << symbolName << "'"
                                 << " found at position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                            outfile << "\t"
                                    << "'" << symbolName << "'"
                                    << " found at position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                        }
                        else
                        {
                            cout << "\t"
                                 << "'" << symbolName << "'"
                                 << " not found in any of the ScopeTables" << endl;
                            outfile << "\t"
                                    << "'" << symbolName << "'"
                                    << " not found in any of the ScopeTables" << endl;
                        }
                    }
                }
            }

            else if (order == "D")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 1)
                {
                    cout << "\tWrong number of arugments for the command " << order << endl;
                    outfile << "\tWrong number of arugments for the command " << order << endl;
                }
                else
                {

                    iss.clear();
                    iss.seekg(0);
                    iss >> order;

                    string symbolName;
                    string tableId = symbolTable->getCurrentTableId();

                    if (iss >> symbolName)
                    {
                        long long indexNo , subIndexNo ;
                        symbolTable->findIndex(symbolName, indexNo, subIndexNo);

                        bool retVal = symbolTable->Remove(symbolName);

                        if (retVal)
                        {
                            // get the position where to delete
                            cout << "\t"
                                 << "Deleted "
                                 << "'" << symbolName << "'"
                                 << " from position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                            outfile << "\t"
                                    << "Deleted "
                                    << "'" << symbolName << "'"
                                    << " from position <" << indexNo << ", " << subIndexNo << "> of ScopeTable# " << tableId << endl;
                        }
                        else
                        {
                            // get the scopeTable id
                            cout << "\tNot found in the current ScopeTable# " << tableId << endl;
                            outfile << "\tNot found in the current ScopeTable# " << tableId << endl;
                        }
                    }
                }
            }

            else if (order == "P")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 1)
                {
                    cout << "\tWrong number of arugments for the command " << order << endl;
                    outfile << "\tWrong number of arugments for the command " << order << endl;
                }
                else
                {
                    iss.clear();
                    iss.seekg(0);
                    iss >> order;

                    string checkOrder;

                    if (iss >> checkOrder)
                    {
                        if (checkOrder == "C")
                            symbolTable->PrintCurrentScopeTable(outfile);
                        else if (checkOrder == "A")
                            symbolTable->PrintAllScopeTable(outfile);
                        else
                            cout << "\tInvalid argument for the command P"<< endl;
                            outfile << "\tInvalid argument for the command P"<< endl;
                    }
                }
            }



            else if (order == "S")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 0)
                {
                    cout << "\tWrong number of arugments for the command " << order << endl;
                    outfile << "\tWrong number of arugments for the command " << order << endl;
                }
                else
                {
                    symbolTable->EnterScope();
                    string tableId = symbolTable->getCurrentTableId();
                    tableId = symbolTable->getCurrentTableId();
                    // get the current scope table id and replace it
                    cout << "\tScopeTable# " << tableId << " created" << endl;
                    outfile << "\tScopeTable# " << tableId << " created" << endl;
                }
            }



            else if (order == "E")
            {
                int wordCount = distance(istream_iterator<string>(iss), istream_iterator<string>());

                if (wordCount != 0)
                {
                    cout << "\tWrong number of arugments for the command " << order << endl;
                    outfile << "\tWrong number of arugments for the command " << order << endl;
                }
                else
                {
                    string tableId = symbolTable->getCurrentTableId();

                    bool retVal =  symbolTable->ExitScope();

                    if(!retVal)
                    {
                        cout << "\tScopeTable# 1 cannot be deleted"<< endl;
                    }
                    else{
                        // get the current scope id then replace it
                        cout << "\tScopeTable# " << tableId << " deleted" << endl;
                        outfile << "\tScopeTable# " << tableId << " deleted" << endl;
                    }
        
                }
            }
        }

        else
        {
            // Handle the case where the line is empty
            cout << "Line is empty." << endl;
        }
    }

    return 0;
}
