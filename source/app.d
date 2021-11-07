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

void main(){
	mixin makecolors!();
	loaddefualtcolors;
	import undomachine;
	undo!(game_,10) game; game.init;
	delayassign!int input;
	int stacking=0;
	InitAudioDevice();
	Sound soundundo;
	Sound soundmove;
	Sound soundstack;
	Sound soundhappy;
	
	soundundo = LoadSound("glass_006.ogg");
	soundmove = LoadSound("click2.ogg");
	soundstack= LoadSound("cardSlide6.ogg");
	soundhappy= LoadSound("chipsStack2.ogg");
	//game.p.getpile(0).writeln;
	mixin(import("drawing.mix"));
	struct drawing_{
		aristotlegoto!(card,10)[52] cards;//I commented out the assert in machines.counter to make this work.... Im afriad
		aristotlegoto!(bool,.07)[52] flipping;
		void init(card[63] inputs){
			foreach(i;0..52){
				flipping[i]+=inputs[i].flipped;
				static foreach(z;0..10){flipping[i]++;}
		}}
		void draw__(card[63] inputs){
			foreach(i;0..52){
				cards[i].flipped=inputs[i].flipped;
				if(cards[i].state.current.p!=inputs[i].p){//why are these if statements nessery?
					cards[i]+=inputs[i];
					cards[i]++;
					//cards[i].writeln;
					//auto temp=inputs[i].flipped;
					inputs[i]=cards[i];
					//inputs[i].flipped=temp;
					inputs[i].h+=50;
				}
				//if(flipping[i].state.current!=inputs[i].flipped){
					//flipping[i].writeln;
					//float(flipping[i]).writeln;
					flipping[i]+=inputs[i].flipped;
					flipping[i]++;
					//cards[i].writeln;
					inputs[i].flipped=flipping[i]>.5;
					//inputs[i].h+=50;
				//}
			}
			foreach(c;inputs.drawsort){
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
				if(c.i<52&& c.i >=0){
					draw3(c,g(f(flipping[c.i])),0);
				}else{
					draw3(c,1,0);
				}
			}
		}
	}
	drawing_ drawer;
	drawer.init(game);
	while (!WindowShouldClose()){
		BeginDrawing();
			ClearBackground(background);
			if(IsMouseButtonPressed(0)){
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
			if(IsKeyPressed(KeyboardKey.KEY_SPACE)||IsMouseButtonPressed(1)){
				PlaySound(soundmove);
				game+=magicpair;
				stacking=-30;
			}
			if(IsKeyDown(KeyboardKey.KEY_SPACE)||IsMouseButtonDown(1)){
				stacking++;
				if(stacking%10==0 && stacking >0){
					PlaySound(soundhappy);
					int i=stacking/10;
					game+=faststack(card(rotateiter(i)));
				}
			}
			if(IsKeyPressed(KeyboardKey.KEY_Z)){
				game--;
				PlaySound(soundundo);
			}
			if(IsKeyPressed(KeyboardKey.KEY_F10)){
				//debug_= ! debug_;
			}
			if(IsKeyPressed(KeyboardKey.KEY_F11)){
				changecolors;
			}
			//foreach(c;game.drawsort){
			//	draw(c,1,0);
			//}
			drawer.draw__(game);
			//game.get.writeln;
			//DrawFPS(10,10);
		EndDrawing();
	}
	CloseWindow();
}