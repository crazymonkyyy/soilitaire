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
	static if(__traits(compiles,mixin("foresight"))){//"foresight()" will break things fickle code
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
bool isbullshit(T)(T i){
	return i==bullshitof!T;}
float distence(bool a,bool b){
	if(a==b){return 0.0;}
	return 1.0;
}
float distence(float a, float b){
	if(a>b){return a-b;}
	return b-a;
}
float lerp(bool a,bool b,float f){
	if(f==1){return a;}
	if(f==0){return b;}
	if(a==b){return a;}
	if(a){
		return 1-f;
	} else {
		return f;
	}
}
float lerp(float a,float b,float f){
	import std.math;
	if(f.isNaN){return a;}
	return a*(1-f)+b*f;
}

template bullshitof(T:bool){
	enum bullshitof=false;}
template bullshitof(T:float){
	enum bullshitof=-1.0;}
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
		static if(is(T==float)){
			if(!a<.5){a=1;}//what a horrifing hack
			if(a<.5){a=0;}
		}
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
float sanity(float f){
	if(!f>0){return 0;}//attempting to get nan
	if(f>1){return 1;}
	return f;
}
struct slowlerp(T_,int slow_=10){
	alias T=typeof(T_().lerp(T_(),float()));
	delayassign!T state;
	counter!slow_ count;
	ref int slow(){return count.max;}//cause its speed^-1 mmmmmk
	auto get(){
		return state.lerp(state[1], sanity(cast(float)count/slow));}
	void poke(){
		if( ! state.isstable){count++;}
		if(count.ishalt){
			state++;
			count.i=0;
		}
	}
	void give(T a){
		if(state.future==a){return;}
		state+=get;
		count.i=0;
		state++;
		state+=a;
	}
	T foresight(int i){
		int j=count+i;
		if(j>slow){return state[1];}
		return state.lerp(state[1], cast(float)j/slow);
	}
	bool isstable(){return count.ishalt||state.isstable;}
	mixin machineopoverloads!();
}
//unittest{
//	slowlerp!int foo;
//	foo+=1;
//	foo+=10;
//	foreach(i;0..15){
//		foo.get.writeln;foo++;}
//}

template aristotlegoto(T,alias speed){
	alias D=typeof(T().distence(T()));
	struct aristotlegoto_(T,D speed_){
		slowlerp!T mach; alias mach this;
		D speed=speed_;
		void give(T a){
			mach.slow=1;//???? without this it wasnt initualizing a new state correcly for whatever reason
			mach+=a;
			import std.conv;
			mach.slow=(mach.state[0].distence(mach.state[1])/speed).to!int;
			if(mach.slow>100){
				mach.slow=1;
				mach++;
				static if(is(T==bool)){
					mach+=a;
				}
			}
		}
		bool isstable(){return mach.isstable || mach.get.isbullshit;}
		mixin compositionopoverloads!();//is this correct? Its not really a composite but im just motifing a single function
	}
	alias aristotlegoto=aristotlegoto_!(T,speed);
}
//unittest{
//	aristotlegoto!(int, 3) foo;
//	foo+=1;
//	foo+=9;
//	foreach(i;1..5){
//		foo.get.writeln;foo++;
//	}
//	foo+=-7;
//	foreach(i;1..10){
//		foo.get.writeln;foo++;
//	}
//}
template path(M,alias speed){//makes 2 bullshit states for some reason todo
	alias T=typeof(M().get());
	//alias D=typeof(distence(T(),T()));
	struct path_{
		M points;
		aristotlegoto!(T,speed) where;
		auto get(){return where.get;}
		void poke(){
			if(where.isstable){
				where+=points.get;
				points++; where++;
			}else{
				where++;
		}}
		auto give(T)(T a){points+=a;}
		mixin machineopoverloads!();
	}
	alias path=path_;
}
struct counter(int to=10){
	int i;
	int max=to;
	auto get(){return i;}
	void poke(){i++;}//assert(! (i>max));}
	bool ishalt(){return i==max;}
	mixin machineopoverloads!();
}