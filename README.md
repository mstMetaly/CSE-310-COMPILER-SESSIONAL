# CSE 310 Compiler Design Sessional

This repository contains the implementation of a complete compiler for a subset of the C programming language, developed as part of the CSE 310 Compiler Design course. The compiler is implemented in four phases, each building upon the previous one.

## 📁 Project Structure

```
CSE_310_COMPILER_SESSIONAL/
├── OFFLINE1_SymbolTable/          # Phase 1: Symbol Table Implementation
│   ├── 2005110/                   # Student implementation
│   └── Resources/                 # Specifications and test cases
├── OFFLINE2_LexicalAnalysis/      # Phase 2: Lexical Analyzer
│   ├── 2005110/                   # Student implementation
│   └── Resources/                 # Specifications and sample code
├── OFFLINE3_ParserGenerator/      # Phase 3: Parser Generator (YACC/Bison)
│   ├── 2005110/                   # Student implementation
│   └── Resources/                 # Specifications and demo code
└── OFFLINE4_ICG/                  # Phase 4: Intermediate Code Generation
    ├── 2005110/                   # Student implementation
    └── Resources/                 # Specifications and test cases
```

## 🚀 Compiler Phases

### Phase 1: Symbol Table Implementation
**Location**: `OFFLINE1_SymbolTable/2005110/`

A hash table-based symbol table implementation with scope management.

**Features**:
- Hash table with chaining for collision resolution
- Scope management (nested scopes)
- Insert, Lookup, Delete operations
- Print functionality for debugging

**Commands**:
- `I <name> <type>` - Insert symbol
- `L <name>` - Lookup symbol
- `D <name>` - Delete symbol
- `P <A/C>` - Print symbol table (All/Current scope)
- `S` - Enter new scope
- `E` - Exit current scope
- `Q` - Quit

**Compilation & Execution**:
```bash
cd OFFLINE1_SymbolTable/2005110/
g++ -o symbol_table 2005110_main.cpp
./symbol_table
```

### Phase 2: Lexical Analyzer
**Location**: `OFFLINE2_LexicalAnalysis/2005110/`

A lexical analyzer implemented using Flex (Fast Lexical Analyzer Generator).

**Features**:
- Token recognition for C subset
- Error handling and reporting
- Line number tracking
- Indentation checking
- Symbol table integration

**Supported Tokens**:
- Keywords: `int`, `float`, `double`, `if`, `else`, `for`, `while`, `return`, etc.
- Identifiers, literals, operators
- Comments (single-line and multi-line)
- String literals with escape sequences

**Compilation & Execution**:
```bash
cd OFFLINE2_LexicalAnalysis/2005110/
./run.sh
# or manually:
flex -o 2005110.cpp 2005110.l
g++ 2005110.cpp -o 2005110.out
./2005110.out input.txt
```

### Phase 3: Parser Generator (YACC/Bison)
**Location**: `OFFLINE3_ParserGenerator/2005110/`

A parser for C subset using YACC/Bison with semantic analysis.

**Features**:
- Context-free grammar implementation
- Semantic analysis
- Type checking
- Error recovery
- Symbol table integration

**Grammar Coverage**:
- Variable declarations and assignments
- Function declarations and definitions
- Control structures (if-else, loops)
- Expressions and operators
- Array operations

**Compilation & Execution**:
```bash
cd OFFLINE3_ParserGenerator/2005110/
yacc -d -y 2005110.y
g++ -w -c -o y.o y.tab.c
flex 2005110.l
g++ -fpermissive -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o 2005110
./2005110 input.c
```

### Phase 4: Intermediate Code Generation (ICG)
**Location**: `OFFLINE4_ICG/2005110/`

Intermediate code generation with assembly-like output.

**Features**:
- Three-address code generation
- Control flow management
- Expression evaluation
- Function call handling
- Assembly-like output format

**Output Format**:
- Assembly-style instructions
- Label management
- Variable allocation
- Control flow labels

**Compilation & Execution**:
```bash
cd OFFLINE4_ICG/2005110/
./run.sh
# or manually:
yacc -d -y 2005110.y
g++ -w -c -o y.o y.tab.c
flex 2005110.l
g++ -fpermissive -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o 2005110
./2005110 test.c
```

## 🛠️ Prerequisites

### Required Tools
- **GCC/G++**: C++ compiler
- **Flex**: Fast Lexical Analyzer Generator
- **YACC/Bison**: Parser Generator
- **Make**: Build automation (optional)

### Installation

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install flex bison build-essential
```

**macOS**:
```bash
brew install flex bison gcc
```

**Windows**:
- Install MinGW or use WSL
- Install Flex and Bison through package managers

## 📝 Language Features Supported

### Data Types
- `int` - Integer type
- `float` - Floating-point type
- `double` - Double precision floating-point

### Control Structures
- `if-else` statements
- `for` loops
- `while` loops
- `return` statements

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Relational: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `&&`, `||`, `!`
- Assignment: `=`, `+=`, `-=`, `*=`, `/=` (in later phases)
- Increment/Decrement: `++`, `--`

### Functions
- Function declarations and definitions
- Parameter passing
- Return values

### Arrays
- Array declarations
- Array element access
- Array bounds checking

## 🧪 Testing

Each phase includes test cases in the `Resources/` directories:

- **Phase 1**: Input/output files for symbol table operations
- **Phase 2**: Sample C code for lexical analysis
- **Phase 3**: Grammar test cases and sample programs
- **Phase 4**: Test programs for intermediate code generation

### Running Tests
```bash
# Example for Phase 1
cd OFFLINE1_SymbolTable/2005110/
./symbol_table < ../Resources/input.txt > output.txt
diff output.txt ../Resources/output.txt

# Example for Phase 2
cd OFFLINE2_LexicalAnalysis/2005110/
./2005110.out ../Resources/sample.c

# Example for Phase 4
cd OFFLINE4_ICG/2005110/
./2005110 test1_i.c
```

## 📚 Key Files

### Phase 1: Symbol Table
- `2005110_SymbolTable.h` - Main symbol table class
- `2005110_ScopeTable.h` - Scope table implementation
- `2005110_SymbolInfo.h` - Symbol information structure
- `2005110_main.cpp` - Main program with command processing

### Phase 2: Lexical Analyzer
- `2005110.l` - Flex specification file
- `2005110.h` - Header file with declarations
- `2005110_SymbolTable.h` - Symbol table integration
- `run.sh` - Compilation script

### Phase 3: Parser
- `2005110.y` - YACC/Bison grammar file
- `2005110.l` - Lexical analyzer specification
- `2005110.h` - Shared header file

### Phase 4: ICG
- `2005110.y` - Extended grammar with code generation
- `2005110.l` - Lexical analyzer
- `2005110.h` - Header with code generation functions
- `run.sh` - Compilation and execution script

## 🔧 Troubleshooting

### Common Issues

1. **Flex/Bison not found**:
   ```bash
   sudo apt-get install flex bison
   ```

2. **Compilation errors**:
   - Ensure all required headers are included
   - Check for missing semicolons in grammar files
   - Verify symbol table integration

3. **Runtime errors**:
   - Check input file format
   - Verify symbol table operations
   - Ensure proper scope management

### Debug Mode
Add debug flags during compilation:
```bash
g++ -g -o debug_symbol_table 2005110_main.cpp
```

## 📖 Learning Resources

- **Flex Manual**: https://westes.github.io/flex/manual/
- **Bison Manual**: https://www.gnu.org/software/bison/manual/
- **Compiler Design**: Dragon Book (Aho, Lam, Sethi, Ullman)
- **C++ Reference**: https://en.cppreference.com/

## 👨‍💻 Author

**Student ID**: 2005110  
**Course**: CSE 310 - Compiler Design  
**Institution**: Bangladesh University of Engineering and Technology


---

**Note**: This compiler implements a subset of the C programming language and is designed for educational purposes. It may not support all C language features or be suitable for production use. 
