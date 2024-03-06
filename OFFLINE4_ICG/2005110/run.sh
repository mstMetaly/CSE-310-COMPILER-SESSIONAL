yacc -d -y 2005110.y
echo "y.tab.c created"
g++ -w -c -o y.o y.tab.c
flex 2005110.l
echo "lex.yy.c created"
g++ -fpermissive -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o 2005110
./2005110 test.c

