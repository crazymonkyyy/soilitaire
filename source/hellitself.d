import raylib;
import basic;
Vector2[] traversegrid(float starting,int count,Vector2 zero,
		int width,int hieght,Vector2 left,Vector2 up){
	int inversetrianglefunc(int x){
		x+=1;
		import std.math; import std.conv;
		float x_=x*float(2);
		x_=sqrt(x_)+.5;
		x_=floor(x_);
		int y=x_.to!int;
		return y;
	}
	int trianglefunc(int x){
		return x*(x+1)/2;
	}
	
	Vector2 right=-left;
	Vector2 down=-up;
	Vector2 upright=up+right;
	Vector2 downleft=down+left;
	int least(){return min(width,hieght);}
	int greater(){return max(width,hieght);}
	bool which(){return width>=hieght;}
	
	const int breakpoint1=trianglefunc(least-1);
	const int breakpoint2=(width*hieght)-breakpoint1-1;
	const int breakpoint3=width*hieght-1;
	
	int where(float x){
		return 
			x<0?-99:
			x<breakpoint1? 1 :
			x<breakpoint2? 2 :
			x<breakpoint3? 3 :
			-99;
	}
	
	const bool parity1=cast(bool)((least+which)%2);
	const bool parity2=cast(bool)((greater-least)%2);
	
	Vector2 A,B,a,b,dir;
	if(width>hieght){
		A=zero+left*(least-1)-left;
		B=zero+up  *(least-1)-left;
		a=upright;
		b=downleft;
		dir=left;
	} else {
		B=zero+left*(least-1)-up;
		A=zero+up  *(least-1)-up;
		b=upright;
		a=downleft;
		dir=up;
	}
	Vector2 C=left*(width-1)+up*(hieght-1)+zero;
	struct pos{
		int a;
		float b;
		float c;
	}
	pos findpos(float x){
		pos o;
		o.a=inversetrianglefunc(x.ceil.to!int);
		float f=x-trianglefunc(o.a)+o.a+1;
		o.b=min(f,1);
		o.c=f-o.b;
		o.a-=2;
		return o;
	}
	pos findpos2(float x, int w){
		pos o;
		o.a=x.ceil.to!int/w;
		float f=x-o.a*w+1;
		o.b=min(f,1);
		o.c=f-o.b;
		return o;
	}
	
	
	Vector2[] output; output.reserve(count);
	foreach(i_;0..count){
		float i=starting+i_;
		i%=breakpoint3;
		int x=i.floor.to!int;
		int w=where(x);
		if(w==-99){continue;}
		pos p=
			w==1?findpos(i):
			w==2?findpos2(i-breakpoint1,least):
			findpos(breakpoint3-i);
		Vector2 start,side,run;
		if(w==2){
			start=p.a%2==parity1?B:A;
			side =dir;
			run  =p.a%2==parity1?b:a;
		} else {
			start=w==1?zero:C;
			side =w==1?
				((p.a-1)%2?left:up):
				(p.a%2==parity2?-left:-up);
			run  =w==1?
				((p.a-1)%2?upright:downleft):
				(p.a%2==parity2?-upright:-downleft);
		}
		output~=start+
			p.a*side+
			p.b*side+
			p.c*run;
	}
	return output;
}