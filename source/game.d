import basic;
public import machines;
import trinary;
enum f=tri(-1);
enum idk=tri(0);
enum t=tri(1);
int dis(int a, int b){
	if(a>b){return a-b;}
	return b-a;
}
int lerp(int a,int b,float f){
	if(f==0){return a;}
	if(f==1){return b;}
	return cast(int)(a*(1-f)+b*f);
}
struct pos{
	int x; 
	int y;
	bool invalid(){
		return x==-1 && y==-1;
	}
	int distence(pos a){
		return x.dis(a.x)+y.dis(a.y);}
	pos lerp(pos a,float f){
		return pos(x.lerp(a.x,f),y.lerp(a.y,f));}
}

struct card{
	int i;
	pos p;
	int h=-100;
	bool flipped;
	auto rank(){
		return i%13;}
	auto suit(){
		return (i/13)%4;}
	auto color(){
		return i/26;}
	int distence(card a){
		return p.distence(a.p);}
	card lerp(card a,float f){
		assert(i==a.i);
		return card(i,p.lerp(a.p,f),h,flipped);
	}
	enum bullshit=card(-1);
}
struct pair{
	card a;
	card b;
	enum bullshit=pair(card(-1),card(-1));
}
alias zone=intstore;

bool canstack1(pair p){
	if(p.b.i<=-99){return true;}
	return p.a.rank+1==p.b.rank && p.a.color != p.b.color;
}
bool canstack2(pair p){
	import std.algorithm;
	if(p.a.suit != p.b.suit){return false;}
	if(p.a.rank==0 && p.b.rank==0){return true;} 
	return p.b.rank==p.a.rank-1;
}
utri stackstyle(pair p){
	if(p.a.i==-1 ||p.b.i==-1){return utri(0);}
	if(p.canstack1){return utri(1);}
	if(p.canstack2){return utri(2);}
	return utri(0);
}


card[] drawpile_(zone z,int which, int many){
	card[] o; o.reserve(z.length);
	int i;
	if(z.length==0){return o;}
	while(i<which){
		o~=card(z[i],pos(250,0),5,false); i++;}
	foreach(j;0..many){
		o~=card(z[i],pos(100+j*33,0),j,true); i++;}
	while(i<z.length){
		o~=card(z[i],pos(0,0),0,false); i++;}
	return o;
}
struct drawpile{
	zone draw;
	int which=0;
	int many=0;
	auto get(){
		return drawpile_(draw,which,many);}
	void poke(){
		if(draw.store.length==0){return;}
		if(which ==0&& many==0){
			which=0; many=3; return;}
		which+=many;
		many=3;
		if(which >= draw.store.length){
			which=0; many=0; return;}
		if(which + many > draw.store.length){
			import std.conv;
			many=(draw.store.length-which).to!int;
		}
	}
	void give(neg a){
		if(a==-1){return;}
		assert(a== active);
		draw+=a;
		many--;
	}
	int active(){
		if(draw.store.length==0 || many==0){return -1;}
		if(which+many-1>=draw.store.length){"Im confused".writeln;return -1;}
		return draw.store[which+many-1];
	}
	tri valid(pair p){
		import std.algorithm;
		tri a;
		if(active==p.a.i){a=t;}
		else{
			if(draw.store[].canFind(p.a.i)){a=f;}
			else{a=idk;}
		}
		if(draw.store[].canFind(p.b.i)){return f;}
		else return a;
	}
	bool has(card c){
		return draw.has(c.i);
	}
	mixin machineopoverloads!();
}
card[] pile_(zone z,int depth,int x,int y,int h){
	card[] o;
	foreach(j,i;z.store[]){
		o~=card(i,pos(x,y+h*cast(int)j),cast(int)j,j>=depth);
	}
	return o;
}
struct piles{
	zone[7] zones;
	int[7] depths;
	ref auto getpile(int i){
		return pile_(zones[i],depths[i],i*100,150,25);}
	auto get(){
		struct p{
			piles* parent;
			int i;
			auto front(){
				return parent.getpile(i);
			}
			void popFront(){
				i++;}
			bool empty(){
				return i>=7;}
		}
		import std.algorithm;
		return p(&this).joiner;
	}
	auto fakecards(){
		enum zone z=zone([-100]);
		card[7] o;
		foreach(i;0..7){
			o[i]=pile_(z,-100,i*100,150,25)[0];
			o[i].i-=i;
			o[i].h=-10;
			o[i].flipped=true;
		}
		return o;
	}
	bool has(card c){
		if(c.i<-99){return true;}
		foreach(z;zones){
			if(z.has(c.i)){return true;}
		}
		return false;
	}
	bool top(card c){
		if(c.i<-99){return true;}
		foreach(z;zones){ if(z.store.length >0){
			if(z[$-1]==c.i){return true;}
		} }
		return false;
	}
	void verified(pair p){
		if(p.b.i<-99){
			zones[where(p.b).x]+=p.a.i;return;}
		foreach(ref z;zones){ if(z.store.length>0){
			if(z[$-1]==p.b.i){
				z+=p.a.i;return; 
	}}}}
	pos where(card c){
		if(c.i<=-99){
			c.i+=100;
			return pos(-c.i,0);
		}
		foreach(int x,z;zones){
		foreach(int y,e;z.store){
			if(c.i==e){return pos(x,y);}
		}}
		return pos(-1,-1);
	}
	void unverified(pair p){
		//import std.stdio;"pile to pile move".writeln;
		pos a=where(p.a);
		pos b=where(p.b);
		if(a.x==b.x){return;}
		if(a.y<depths[a.x]){return;}
		if(b.y!=zones[b.x].store.length-1 && p.b.i >-99){return;}
		foreach(i;zones[a.x].store[a.y..$]){
			zones[b.x]+=i;
		}
		zones[a.x].store=zones[a.x].store[0..a.y];
	}
	void fliptops(){
		foreach(i,ref d;depths){
			d=min(d,zones[i].store.length-1);
			//zones[i].store.length.writeln;
	}}
	void give(neg a){
		foreach(ref z;zones){
			z+=a;
		}
	}
	mixin machineopoverloads!();
}
card[] endzone_(zone z,int x,int w){
	card[] o;
	import std.range;
	foreach(i;z.store[]){
		o~=card(i,pos(x+w*card(i).suit),card(i).rank,true);
		if(o[$-1].color>1){o[$-1].h=-1;}
		import basic;
		//o[$-1].writeln;
	}
	return o;
}
struct endzone{
	zone z;
	auto get(){
		return endzone_(z,380,100);}
	auto fakecards(){
		return endzone_(zone([52,52+13,52+26,52+39]),380,100);}
	bool has(card c){
		if(c.i>51){return true;}
		return z.has(c.i);
	}
	void give(int i){
		z+=i;
	}
	mixin machineopoverloads!();
}
struct game_{
	import std.range;
	drawpile d;
	piles p;
	endzone e;
	card[63] get(){
		card[63] o;
		foreach(c;chain(d.get,p.get,e.get)){
			assert(o[c.i].h==-100,c.to!string ~o[c.i].to!string);
			o[c.i]=c;
		}
		foreach(i,c;chain(e.fakecards,p.fakecards[]).enumerate){
			o[i+52]=c;
		}
		return o;
	}
	void init(){
		int[52] s;
		foreach(i;0..52){
			s[i]=i;
		}
		import std.random;
		s[].randomShuffle;
		int i;
		foreach(j;0..7){
		foreach(k;0..j+1){
			p.zones[j]+=s[i]; i++;
		}
			p.depths[j]=j;
		}
		foreach(j;i..52){
			d.draw+=s[i];i++;
		}
	}
	void give(pair pair_){
		//import std.stdio;pair_.writeln;
		stackstyle(pair_).writeln;
		pair_.a.rank.writeln("rank");
		pair_.a.suit.writeln("suit");
		pair_.a.color.writeln("color");
		switch(stackstyle(pair_).to!int){
			case 0:return;
			case 1:
				if( ! p.has(pair_.b)){"no".writeln;return;}
				if(e.has(pair_.a)){"what".writeln;return;}
				if(d.active==pair_.a.i){
					if(p.top(pair_.b)){
						p.verified(pair_);
						d+=neg(pair_.a.i);
				}}
				if(p.has(pair_.a)){
					p.unverified(pair_);
				}
				break;
			case 2:
				if( ! e.has(pair_.b)){return;}
				if(e.has(pair_.a)){return;}
				if(p.has(pair_.a)){
					if(! p.top(pair_.a)){ return;}
					p+=neg(pair_.a.i);
					assert(! p.has(pair_.a));
				}
				if(d.has(pair_.a)){
					if(d.active!=pair_.a.i){return;}
					d+=neg(pair_.a.i);
				}
				e+=pair_.a.i;
				break;
			default: assert(0);
		}
		p.fliptops;
	}
	mixin machineopoverloads!();
}
card[i] drawsort(int i)(card[i] c){
	import std.algorithm;
	c[].sort!("a.h<b.h");
	return c;
}