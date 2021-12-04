import game;
import raylib;
import basic;
import std.math;
pos topos(Vector2 a){
	return pos(a.x.to!int,a.y.to!int);}
card[63] endscreen1(T)(T game,int j){
	import std.range;
	card[63] o;
	foreach(i,c;chain(game.e.fakecards,game.p.fakecards[]).enumerate){
		o[i+52]=c;
	}
	float centerx=400;//todo center it properly
	float centery=300;
	float layer=4.7+sin(j/float(8000))*1.6;
	float scale=300;
	float starting=.02*j;
	int offset=starting.to!int%52;
	starting=starting-trunc(starting);
	float layerdistence=.3;
	Vector2 spiral(float i){
		i+=1+starting;
		float angle=(std.math.PI*2)/layer;
		return Vector2(
				sin(i*angle),
				cos(i*angle)
			)
			*log((i/layer)*layerdistence+1)
			//*(i/float(100))
			*scale
			+Vector2(centerx,centery);
	}
	
	float swap=j*.008;
	float cycle=.07+sin(j/float(1000))*.25;
	foreach(i;0..52){
		int k=(i+52-offset)%52;
		float flip=swap+k*cycle;
		o[k]=card(k,spiral(i).topos,k,(flip.to!int%2).to!bool);}
	return o;
}
pos p;
int xv;
int yv;
int which=52;
card[63] endscreen2(T)(T game){
	import std.range;
	card[63] o=game;
	//foreach(i,c;chain(game.e.fakecards,game.p.fakecards[]).enumerate){
	//	o[i+52]=c;
	//}
	if(which<0){goto exit;}
	if(p.x<-50 || p.x >800+50|| which==52){
		which--;
		p=o[which].p;
		import std.random;
		xv=uniform(-10,10);if(xv==0){xv=1;}
		yv=uniform(-10,10);
	}
	p.x+=xv;
	p.y+=yv;
	if(p.y>500&&yv>0){yv=-yv;}
	yv+=1;
	o[which].p=p;
	o[which].flipped=true;
	foreach(i;which+1..52){
		o[i].p=pos(-200,-100);}
	exit:
	return o;
}
card[63] endscreen3(T)(T game,int j){
	import std.range;
	import hellitself;
	//Vector2[] traversegrid(float starting,int count,Vector2 zero,
	//int width,int hieght,Vector2 left,Vector2 up){
	auto vecs=traversegrid(j/float(50),52,Vector2(0,0),11,6,Vector2(75,0),Vector2(0,105));
	card[63] o;
	foreach(i,c;chain(game.e.fakecards,game.p.fakecards[]).enumerate){
		o[i+52]=c;
	}
	float cycle=.1+(sin(j/float(100))+1)*.001;
	float swap=j/float(200);
	foreach(i;0..52){
		float flip=swap+i*cycle;
		//if(i==3){(flip.to!int%2).to!bool.write;}
		o[i]=card(i,vecs[i].topos,i,(flip.to!int%2).to!bool);
		//if(i==3){o[3].flipped.writeln;}
	}
	return o;
}