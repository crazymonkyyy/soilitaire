/*
there are 3 types:
	* bol: my bool that has my operators
	* tri: balence triarny as a -,?,+ scheme
	* utri: unbalenced tri as 0,1,2

operators:
	* &, min
	* |, max
	* ^, xor
	* +, sum
	* *, consenous, if a==b,a otherwise ?
	* ^^, any, takes input from either a or b, true and false cancel out
	* ~, not
	* ++,rotate
	* [], hacky "ternary" operator
	(anti min and max could have been implimented trivailly but I couldnt imagine a usecase)
	
	compile this with unit tests to get truth tables
*/


//compiosition ulitys

bol notbool(bool b){return bol(b);}//hack to allow for bool to be used, but to not care about it
ref bol notbool(return ref bol b){return b;} 
ref tri notbool(return ref tri b){return b;} 
ref utri notbool(return ref utri b){return b;} 
unittest{
	auto a=bool();notbool(a);
	auto b=bol(); notbool(b);
	auto c=tri(); notbool(c);
	auto d=utri();notbool(d);
}

template typeorder(T:bol,S:bol){enum typeorder=true;}//"sorting" the types so I only have "half" the impl, and to pinky promise assoitivity
template typeorder(T:tri,S:tri){enum typeorder=true;}
template typeorder(T:utri,S:utri){enum typeorder=true;}

template typeorder(T:bol,S:tri){enum typeorder=true;}
template typeorder(T:bol,S:utri){enum typeorder=true;}

template typeorder(T:tri,S:utri){enum typeorder=true;}

template typeorder(T,S){enum typeorder=false;}

int tocase_(T:bol)(T b){
	if(b==T(false)){return 0;}
	return 1;
}
int tocase_(T:tri)(T b){
	if(b==T(-1)){return 0;}
	if(b==T(0)){return 1;}
	return 2;
}
int tocase_(T:utri)(T b){
	if(b==T(0)){return 0;}
	if(b==T(1)){return 1;}
	return 2;
}
template casefactor(T:bol){enum casefactor=2;}
template casefactor(T){enum casefactor=3;}
int tocase(T,S)(T a,S b){
	return a.tocase_*casefactor!S+b.tocase_;}
unittest{
	assert(tocase(bol(false),bol(false))==0);
	//assert(tocase(tri(1),bol(false))==5);
	assert(tocase(utri(0),tri(-1))==0);
	assert(tocase(bol(false),tri(1))==2);
}
template shorthand(char c:'T'){ enum shorthand=true;}
template shorthand(char c:'F'){ enum shorthand=false;}
template shorthand(char c:'t'){ enum shorthand=bol(true);}
template shorthand(char c:'f'){ enum shorthand=bol(false);}
template shorthand(char c:'-'){ enum shorthand=tri(-1);}
template shorthand(char c:'?'){ enum shorthand=tri(0);}
template shorthand(char c:'+'){ enum shorthand=tri(1);}
template shorthand(char c:'0'){ enum shorthand=utri(0);}
template shorthand(char c:'1'){ enum shorthand=utri(1);}
template shorthand(char c:'2'){ enum shorthand=utri(2);}
//shared code mixins
mixin template truthstring(string s){
	auto f(typeof(a) a,typeof(b) b){//why do I need to wrap my copy and paste :thonk:
		switch(tocase(a,b)){
			static foreach(i,c;s){
				case i: return shorthand!c;
			}
			default: assert(0);
		}
	}
}

mixin template bulk(){
	auto opBinary(string op:"&",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return and(this,notbool(a));
		} else {
			return and(notbool(a),this);}
	}
	auto opBinary(string op:"|",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return or(this,notbool(a));
		} else {
			return or(notbool(a),this);}
	}
	auto opBinary(string op:"+",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return sum(this,notbool(a));
		} else {
			return sum(notbool(a),this);}
	}
	auto opBinary(string op:"^",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return xor(this,notbool(a));
		} else {
			return xor(notbool(a),this);}
	}
	auto opBinary(string op:"*",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return cons(this,notbool(a));
		} else {
			return cons(notbool(a),this);}
	}
	auto opBinary(string op:"^^",T)(T a){
		static if(typeorder!(typeof(this),T)){
			return any(this,notbool(a));
		} else {
			return any(notbool(a),this);}
	}
	auto opEquals(T:typeof(this))(T a){return b==a.b;}
	auto opEquals(T)(T a){
		static if(typeorder!(typeof(this),T)){
			return equ(this,notbool(a));
		} else {
			return equ(notbool(a),this);}
	}
}

//the types
struct bol{//my bool type, cause while its possible to do things with opBinaryRight, I believe its buggy, also annoying as all fuck
	bool b;
	string toString(){return b?"t":"f";}
	mixin bulk!();
	T opIndex(T)(T x,T y){
		if(b){return y;}
		return x;
	}
	bol opUnary(string op:"~")(){return this[bol(true),bol(false)];}
	bol opUnary(string op:"++")(){return this[bol(true),bol(false)];}
	bol opUnary(string op:"--")(){return this[bol(true),bol(false)];}
	
	auto to(T:tri)(){return this[tri(-1),tri(1)];}
	auto to(T:utri)(){return this[utri(0),utri(1)];}
	auto to(T:int)(){return this[0,1];}
	auto to(T:bool)(){return b;}
	
	auto to(T:typeof(this))(){return this;}//honestly just here to make unittesting easier
}
struct tri{//balenced, thinks of bool as -1,1
	byte b;
	this(int i){
		if(i<0){b=-1;return;}
		if(i>0){b=1;return;}
		b=0;
	}
	string toString(){
		if(b<0){return"-";}
		if(b>0){return"+";}
		return "?";
	}
	mixin bulk!();
	T opIndex(T)(T x,T y,T z){
		if(this==tri(-1)){return x;}
		if(this==tri(0)){return y;}
		return z;
	}
	tri opUnary(string op:"~")(){return this[tri(1),tri(0),tri(-1)];}
	tri opUnary(string op:"++")(){return this[tri(0),tri(1),tri(-1)];}
	tri opUnary(string op:"--")(){return this[tri(1),tri(-1),tri(0)];}
	
	auto to(T:bol)(){return this[bol(false),bol(false),bol(true)];}
	auto to(T:utri)(){return this[utri(0),utri(1),utri(2)];}
	auto to(T:int)(){return this[-1,0,1];}
	auto to(T:bool)(){return this[false,false,true];}
	
	auto to(T:typeof(this))(){return this;}
}
struct utri{//unbalenced, thinks of bool as 0,1
	byte b;
	string toString(){
		if(b<1){return"0";}
		if(b>1){return"2";}
		return "1";
	}
	mixin bulk!();
	T opIndex(T)(T x,T y,T z){
		if(this==utri(0)){return x;}
		if(this==utri(1)){return y;}
		return z;
	}
	utri opUnary(string op:"~")(){return this[utri(2),utri(1),utri(0)];}
	utri opUnary(string op:"++")(){return this[utri(2),utri(0),utri(1)];}
	utri opUnary(string op:"--")(){return this[utri(1),utri(2),utri(0)];}
		
	auto to(T:bol)(){return this[bol(false),bol(true),bol(true)];}
	auto to(T:tri)(){return this[tri(-1),tri(0),tri(1)];}
	auto to(T:int)(){return this[0,1,2];}
	auto to(T:bool)(){return this[false,true,true];}
	
	auto to(T:typeof(this))(){return this;}
}
//the truth tables
auto and(T:bol,S:bol)  (T a,S b){ mixin truthstring!"ffft";     return f(a,b);}
auto and(T:tri,S:tri)  (T a,S b){ mixin truthstring!"----??-?+";return f(a,b);}
auto and(T:utri,S:utri)(T a,S b){ mixin truthstring!"000011012";return f(a,b);}
auto and(T:bol,S:tri)  (T a,S b){ mixin truthstring!"----?+";   return f(a,b);}
auto and(T:bol,S:utri) (T a,S b){ mixin truthstring!"fffftt";   return f(a,b);}
auto and(T:tri,S:utri) (T a,S b){ mixin truthstring!"ffffttftt";return f(a,b);}

auto or(T:bol,S:bol)  (T a,S b){ mixin truthstring!"fttt";     return f(a,b);}
auto or(T:tri,S:tri)  (T a,S b){ mixin truthstring!"-?+??++++";return f(a,b);}
auto or(T:utri,S:utri)(T a,S b){ mixin truthstring!"012112222";return f(a,b);}
auto or(T:bol,S:tri)  (T a,S b){ mixin truthstring!"-?++++";   return f(a,b);}
auto or(T:bol,S:utri) (T a,S b){ mixin truthstring!"012112";   return f(a,b);}
auto or(T:tri,S:utri) (T a,S b){ mixin truthstring!"012012112";return f(a,b);}

auto sum(T:bol,S:bol)  (T a,S b){ mixin truthstring!"0112";     return f(a,b);}
auto sum(T:tri,S:tri)  (T a,S b){ mixin truthstring!"--?-?+?++";return f(a,b);}
auto sum(T:utri,S:utri)(T a,S b){ mixin truthstring!"012122222";return f(a,b);}
auto sum(T:bol,S:tri)  (T a,S b){ mixin truthstring!"-?++++";   return f(a,b);}
auto sum(T:bol,S:utri) (T a,S b){ mixin truthstring!"012122";   return f(a,b);}
auto sum(T:tri,S:utri) (T a,S b){ mixin truthstring!"001012122";return f(a,b);}

auto xor(T:bol,S:bol)  (T a,S b){ mixin truthstring!"fttf";     return f(a,b);}
auto xor(T:tri,S:tri)  (T a,S b){ mixin truthstring!"-?+???+?-";return f(a,b);}
auto xor(T:utri,S:utri)(T a,S b){ mixin truthstring!"ftttfftff";return f(a,b);}
auto xor(T:bol,S:tri)  (T a,S b){ mixin truthstring!"-?++?-";   return f(a,b);}
auto xor(T:bol,S:utri) (T a,S b){ mixin truthstring!"tffftt";   return f(a,b);}
auto xor(T:tri,S:utri) (T a,S b){ mixin truthstring!"+--???-++";return f(a,b);}

auto cons(T:bol,S:bol)  (T a,S b){ mixin truthstring!"-??+";     return f(a,b);}
auto cons(T:tri,S:tri)  (T a,S b){ mixin truthstring!"-???????+";return f(a,b);}
auto cons(T:utri,S:utri)(T a,S b){ mixin truthstring!"-???+???+";return f(a,b);}
auto cons(T:bol,S:tri)  (T a,S b){ mixin truthstring!"-????+";   return f(a,b);}
auto cons(T:bol,S:utri) (T a,S b){ mixin truthstring!"-???++";   return f(a,b);}
auto cons(T:tri,S:utri) (T a,S b){ mixin truthstring!"-??????++";return f(a,b);}

auto any(T:bol,S:bol)  (T a,S b){ mixin truthstring!"-??+";     return f(a,b);}
auto any(T:tri,S:tri)  (T a,S b){ mixin truthstring!"--?-?+?++";return f(a,b);}
auto any(T:utri,S:utri)(T a,S b){ mixin truthstring!"-?+?+++++";return f(a,b);}
auto any(T:bol,S:tri)  (T a,S b){ mixin truthstring!"--??++";   return f(a,b);}
auto any(T:bol,S:utri) (T a,S b){ mixin truthstring!"-?+?++";   return f(a,b);}
auto any(T:tri,S:utri) (T a,S b){ mixin truthstring!"-?+-++?++";return f(a,b);}

auto equ(T:bol,S:bol)  (T a,S b){ mixin truthstring!"TFFT";     return f(a,b);}
//auto equ(T:tri,S:tri)  (T a,S b){ mixin truthstring!"TFFFTFFFT";return f(a,b);}
//auto equ(T:utri,S:utri)(T a,S b){ mixin truthstring!"TFFFTFFFT";return f(a,b);}
auto equ(T:bol,S:tri)  (T a,S b){ mixin truthstring!"TFFFFT";   return f(a,b);}
auto equ(T:bol,S:utri) (T a,S b){ mixin truthstring!"TFFFTT";   return f(a,b);}
auto equ(T:tri,S:utri) (T a,S b){ mixin truthstring!"TFFFFFFTT";return f(a,b);}
//tests
template testcases(T:bool){enum T[] testcases=[true,false];}
template testcases(T:bol){enum T[] testcases=[bol(true),bol(false)];}
template testcases(T:tri){enum T[] testcases=[tri(-1),tri(0),tri(1)];}
template testcases(T:utri){enum T[] testcases=[utri(0),utri(1),utri(2)];}
template testcasesstring(T:bool){enum testcasesstring="TF";}
template testcasesstring(T:bol){ enum testcasesstring="tf";}
template testcasesstring(T:tri){ enum testcasesstring="-?+";}
template testcasesstring(T:utri){enum testcasesstring="012";}
unittest{
	import std.stdio;
	import std.meta;
	static foreach(op;["&","|","+","^","*","^^","=="]){
	static foreach(T;AliasSeq!(bol,tri,utri)){
	static foreach(S;AliasSeq!(bool,bol,tri,utri)){
		writeln(T.stringof," ",op," ", S.stringof," = ",typeof(mixin("T.init"~op~"(S.init)")).stringof);
		writeln(" |",testcasesstring!S);
		writeln("-----");
	foreach(a;testcases!T){
		write(a,"|");
	foreach(b;testcases!S){
		write(mixin("a"~op~"(b)"));
	}
		writeln();
	}
		writeln();
	}}}
}
unittest{
	import std.meta;
	static foreach(T;AliasSeq!(bol,tri,utri)){
	foreach(a;testcases!T){
		assert(a==~(~a),a.toString);
	}}
}
unittest{
	import std.stdio;
	import std.meta;
	static foreach(T;AliasSeq!(bol,tri,utri)){
	static foreach(S;AliasSeq!(bool,bol,tri,utri)){
	foreach(a;testcases!T){
		writeln(a,".to!",S.stringof," = ",a.to!S);
	}}}
}
unittest{
	import std.meta;
	static foreach(T;AliasSeq!(tri,utri)){
	foreach(a;testcases!T){
		assert(a==++(++(++a)),a.toString);
		assert(a==--(--(--a)),a.toString);
	}}
}