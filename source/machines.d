//import metric;
mixin template machineopoverloads(){
	void opUnary(string s:"++")(){
		this.poke;}
	void opUnary(string s:"--")(){
		this.pull;}
	//import std.traits;
	//static if(hasMember!(this,"get")){
	//static if(__traits(hasMember,this,"get")){
	static if(__traits(compiles,mixin("get()"))){//I dont get it, is traits buggy?
		alias get this;
	}else{
		auto get()(){return this;}
	}
	void opOpAssign(string s:"+",T)(T a){
		give(a);
	}
	static if(__traits(compiles,mixin("foresight()"))){
		auto opIndex(T:int)(T i){//hack to make it wait to be initualized
			return foresight(i);
		}
	}
}
mixin template compositionopoverloads(){
	void opUnary(string s:"++")(){
		this.poke;}
	void opOpAssign(string s:"+",T)(T a){
		give(a);
	}
	auto opIndex(T:int)(T i){return foresight(i);}
}
struct neg{
	int i; alias i this;
}
struct intstore{
	int[] store;
	auto get(){return store;}
	void give(int a){store~=a;}
	void give(neg a){
		import std.algorithm;
		auto index=store.countUntil(a);
		if(index==-1){return;}
		store=store[0..index]~store[index+1..$];
	}
	bool has(int i){
		import std.algorithm;
		return store.canFind(i);
	}
	mixin machineopoverloads!();
}
unittest{
	import basic;
	intstore foo;
	foo+=1;
	foo+=2;
	foo+=neg(1);
	foo.writeln;
}
template bullshitof(T){
	enum bullshitof=T.bullshit;}
template bullshitof(T:int){
	enum bullshitof=int.min;}
bool isbullshit(int i){
	return i==int.min;}
struct delayassign(T){
	T current=bullshitof!T;
	T future=bullshitof!T;
	T get(){ return current;}
	void poke(){current=future;}
	T foresight(int i){
		if(i!=0){return future;}
		else{return current;}
	}
	bool isstable(){return current==future;}
	bool iserror(){return current.isbullshit;}
	void give(T a){
		if(current.isbullshit){current=a;}
		future=a;
	}
	mixin machineopoverloads!();
}
struct parroit(T){
	T[] store;
	T get(){
		if(store.length==0){return bullshitof!T;}
		return store[0];
	}
	void poke(){
		if(store.length>0){
			store=store[1..$];}}
	bool iserror(){return store.length==0;}
	void give(T a){store~=a;}
	mixin machineopoverloads!();
}