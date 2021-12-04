import basic;
int inversetrianglefunc(int x){
	import std.math; import std.conv;
	float x_=x*float(2);
	x_=sqrt(x_)+.5;
	x_=floor(x_);
	int y=x_.to!int;
	return y;
}
int trianglefunc(int x){
	int total;
	foreach(i;1..x+1){
		total+=i;
	}
	return total;
}
unittest{
	foreach(i;1..100){
		i.write(":");
		i.inversetrianglefunc.write("  :");
		(i.inversetrianglefunc-1).trianglefunc.writeln;
	}
}