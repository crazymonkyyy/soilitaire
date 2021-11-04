import basic;
int rotateiter(int i){
	i=i%4*13+i/4;
	return i;
}
unittest{
	bool[52] usedonce;
	foreach(i;0..52){
		i.writeln(",",rotateiter(i));
		assert(usedonce[rotateiter(i)]==false);
		usedonce[rotateiter(i)]=true;
	}
}