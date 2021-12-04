import raylib;
import colorswap;
import basic;
import game;

//DrawTextureRec(cards,tile(7,3),Vector2(100,100),brightwhite);
pair faststack(card c){
	card temp=c;
	if(temp.rank != 0){temp.i--;}
	else{temp.i+=52;}
	return pair(c,temp);
}

int rotateiter(int i){
	i=i%4*13+i/4;
	return i;
}
bool clearbackground=true;
struct endgameswapper(M){
	import machines;
	import endscreens;
	M mach;
	int which=0;
	int i;
	auto get(){
		if(which!=0){i++;}
		switch(which){
			case 0: return mach.get;
			case 1: return endscreen1(mach,i);
			case 2: return endscreen2(mach);
			case 3: return endscreen3(mach,i);
			default: assert(0);
		}
	}
	void give(T)(T a){
		if(which==0){
			mach+=a;
			if(mach.isdone){
				which=uniform(1,4);
				i=uniform(0,1000000);
				if(which==2){clearbackground=false;}
			}
		}else{
			mach=M();
			mach.init;
			which =0;
			clearbackground=true;
		}
	}
	void init(){
		mach.init;
	}
	auto pull(){mach.pull;}
	mixin machineopoverloads!();
}

void main(){
	import undomachine;
	endgameswapper!(undo!(game_,10)) game; game.init;
	delayassign!int input;
	int stacking=0;
	InitAudioDevice();
	int cardhighlight;
	string themename;
	int rendermode;
	
	
	Sound soundundo;
	Sound soundmove;
	Sound soundstack;
	Sound soundhappy;
	
	string soundundo_file;
	string soundmove_file;
	string soundstackfile;
	string soundhappyfile;
	import setting;
	mixin setup!"themes";
	mixin makecolors!("solarized-dark.yaml",);
	void loadthemes(){
		import std.string;
		reload!"themes";
		soundundo = LoadSound(soundundo_file.toStringz);
		soundmove = LoadSound(soundmove_file.toStringz);
		soundstack= LoadSound(soundstackfile.toStringz);
		soundhappy= LoadSound(soundhappyfile.toStringz);
		colors=parsecolors(themename);
	}
	loadthemes();
	//game.p.getpile(0).writeln;
	mixin(import("drawing.mix"));
	struct drawing_{
		aristotlegoto!(card,10)[52] cards;//I commented out the assert in machines.counter to make this work.... Im afriad
		float[52] flipping;
		void init(card[63] inputs){
			foreach(i;0..52){
				flipping[i]=inputs[i].flipped;
				static foreach(z;0..10){flipping[i]++;}
		}}
		void draw__(card[63] inputs){
			//inputs[3].flipped.writeln;
			foreach(i;0..52){
				if(cards[i].state.current.p!=inputs[i].p){//why are these if statements nessery?
					cards[i]+=inputs[i];
					cards[i]++;
					//cards[i].writeln;
					auto temp=inputs[i].flipped;
					inputs[i]=cards[i];
					inputs[i].flipped=temp;
					inputs[i].h+=50;
				}
				{
					if(inputs[i].flipped){
						flipping[i]+=.1;
					} else {
						flipping[i]-=.1;
					}
					flipping[i]=min(1,max(0,flipping[i]));
					//if(i==3){flipping[i].writeln;inputs[i].flipped.writeln;}
					inputs[i].flipped=flipping[i]>.5;
				}
			}
			auto f(float f){
				if(f<0){return 0;}
				if(f>1){return 1;}//this is such a mess
				if(f<.5){
					return 1-f*2;
				}else{
					return f;
				}
			}
			auto g(float g){
				return g*g;
			}
			switch(rendermode){
				case 1:
				foreach(c;inputs.drawsort){
					if(c.i<52&& c.i >=0){
						draw(c,g(f(flipping[c.i])),0);
					}else{
						draw(c,1,0);
					}
				} break;
				case 2:
				foreach(c;inputs.drawsort){
					if(c.i<52&& c.i >=0){
						draw2(c,g(f(flipping[c.i])),0);
					}else{
						draw2(c,1,0);
					}
				}
				default:
				foreach(c;inputs.drawsort){
					if(c.i<52&& c.i >=0){
						draw3(c,g(f(flipping[c.i])),0);
					}else{
						draw3(c,1,0);
					}
				}break;
			}
		}
	}
	drawing_ drawer;
	drawer.init(game);
	int endscreeni;
	while (!WindowShouldClose()){
		BeginDrawing();
			if(clearbackground){ClearBackground(background);}
			if(IsKeyDown(KeyboardKey.KEY_F1)){
				DrawTexture(helpz,0,0,Colors.WHITE);
				goto exit;
			}
			if(IsMouseButtonPressed(0)){
				if(GetMouseX<100&&GetMouseY<130){goto draw;}
				card click;
				click.i=-1;
				click.h=-99;
				foreach(c;game.get){if(clicked(c)){//has a preference for small i cards.... but im not sure that matters at the moment
					if(click.h<c.h && c.flipped){
						click=c;}
				}}
				input++;
				input+=click.i;
				if(input.current!=input.future){
					PlaySound(soundstack);
					game+=pair(card(input.current),card(input.future));
				}else{
					PlaySound(soundhappy);
					game+=faststack(card(input.current));
				}
			}
			if(IsKeyPressed(KeyboardKey.KEY_SPACE)||IsMouseButtonPressed(1)){draw:
				PlaySound(soundmove);
				game+=magicpair;
				stacking=-30;
			}
			if(IsKeyDown(KeyboardKey.KEY_SPACE)||IsMouseButtonDown(1)){
				stacking++;
				if(stacking%10==0 && stacking >0){
					PlaySound(soundhappy);
					int i=stacking/10;
					if(i>52){goto draw;}
					game+=faststack(card(rotateiter(i)));
				}
			}
			if(IsKeyPressed(KeyboardKey.KEY_Z)){
				game--;
				PlaySound(soundundo);
			}
			//if(IsKeyPressed(KeyboardKey.KEY_F2)){
			//	game.mach.game.done=true;
			//}
			if(IsKeyPressed(KeyboardKey.KEY_F10)){
				import std.process;
				auto config=Config.stderrPassThrough;
				"xdg-open themes.conf".executeShell(null,config);
				loadthemes();
			}
			if(IsKeyPressed(KeyboardKey.KEY_F11)){
				changecolors;
			}
			//foreach(c;game.drawsort){
			//	draw(c,1,0);
			//
			//endscreeni++;//if(endscreeni>100){endscreeni=0;}
			//drawer.draw__(endscreen3(game,endscreeni));
			//game.get.writeln;
			//DrawFPS(10,10);
			exit:
			drawer.draw__(game);
		EndDrawing();
	}
	CloseWindow();
}