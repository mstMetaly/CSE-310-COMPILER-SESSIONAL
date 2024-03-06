//all okay
int a,b,c;

void func_a(){
	a = 7;
}

int foo(int a){
	a = a + 3;
	return a;
}


int bar(int a, int b){	
	c = 4*a + 2*b;
	return c;
}

int main(){
 
	int i,j,k,l;
	
	i = 5;
	j = 6;
	
	func_a();
	println(a);//7
	
	k = foo(i);
	println(k);//8
	
	l = bar(i,j);
	println(l);//32
	
	j = 6 * bar(i,j) + 2 - 3 * foo(i);
	println(j);//170
	
 
 	return 0;
 }

