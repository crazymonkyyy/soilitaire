auto fixstring(T)(T a){
	return a;
}
auto fixstring(T:string)(T a){
	return a[1..$-1].dup;
}

template readline_(string mix){
	void readline(string mix_:mix)(string s){
		static assert(mix!="s","you cant use varibles named s -me");
		assert(s[0..mix.length+1]==mix~"=");
		string leftover=s[mix.length+1..$-1].dup;//why does this dup seem nessrery?
		import std.conv;
		mixin(mix)=leftover.to!(typeof(mixin(mix))).fixstring;
	}
}
string dropequals(string s){
	import std.string;
	auto i=s.indexOfAny("=");
	return s[0..i];
}
unittest{assert("bar=1;".dropequals=="bar");}
void donothing(){};
template setup(string s,alias errorfunction=donothing){
	auto mixfile(string s_:s)(){
		enum mix=s~".mix";
		return import(mix);
	}
	void copydefaults(string s_:s)(){
		import std.file;
		try{copy(s~".conf",s~".badformating");}
		catch(Throwable){}
		try{remove(s~".conf");}
		catch(Throwable){}
		try{write(s~".conf",mixfile!s);}
		catch(Throwable){}
	}
	import std.string;
	import std.algorithm;
	static foreach(t;mixfile!s.lineSplitter.map!dropequals){
		mixin readline_!t;
	}
	void reload(string s_:s)(){
		try{
			auto file=File(s~".conf").byLine;
			static foreach(t;mixfile!s.lineSplitter.map!dropequals){
				readline!t(cast(string)file.front);
				file.popFront;
			}
		}
		catch(Throwable){
			errorfunction();
			copydefaults!s();
			reload!s();
		}
	}
}