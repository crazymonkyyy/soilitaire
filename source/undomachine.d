struct nullable(T){
	T payload;
	bool isnull=true;
	void opAssign(T foo){
		payload=foo; isnull=false;}
	this(T a){
		payload=a;
		isnull=false;
	}
	alias payload this;
	//enum bullshit=this.init;
}
struct undo(M,int maxundos){
	M game;
	M gameold;
	import std.traits;
	alias I=Parameters!(M().give)[0];
	import machines;
	parroit!I storedinput;
	int timedelay=0;
	ref M get(){return game;}
	void give(I i){
		auto temp=game;
		game+=i;
		if(game!=temp){
			if(timedelay==maxundos){
				gameold+=storedinput;storedinput++;
				storedinput+=i;
			} else {
				timedelay++;
				storedinput+=i;
			}
		}
	}
	M foresight(int i){
		assert(i<0);
		//assert(timedelay+i>=0,"not implimented");//may be to egger?
		if(timedelay+i>=0){i=-timedelay;}
		int setup=timedelay+i;
		M gamenew=gameold;
		parroit!I inputs=storedinput;
		foreach(j;0..timedelay+1){
			gamenew+=inputs;
			inputs++;
		}
		return gamenew;
	}
	void pull(){
		game=foresight(-1);
		if(storedinput.store.length>0){
			storedinput.store=storedinput.store[0..$-1];}
		timedelay--;
	}
	void init(){
		game.init;
		gameold=game;
	}
	bool isdone(){return game.isdone;}
	mixin machineopoverloads!();
}