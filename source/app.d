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
	game_ game; game.init;
	delayassign!int input;
	int stacking=0;
	//game.p.getpile(0).writeln;
	mixin(import("drawing.mix"));
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
					game+=pair(card(input.current),card(input.future));
				}else{
					game+=faststack(card(input.current));
				}
			}
			if(IsKeyPressed(KeyboardKey.KEY_SPACE)||IsMouseButtonPressed(1)){
				game.d++;
				game.d.active.writeln;
				stacking=-30;
			}
			if(IsKeyDown(KeyboardKey.KEY_SPACE)||IsMouseButtonDown(1)){
				stacking++;
				if(stacking%5==0 && stacking >0){
					int i=stacking/10;
					game+=faststack(card(rotateiter(i)));
				}
			}
			if(IsKeyPressed(KeyboardKey.KEY_Z)){
				//drawpile_.active.writeln;
				//drawpile_+=neg(drawpile_.active);
				//drawpile_.active.writeln;
			}
			if(IsKeyPressed(KeyboardKey.KEY_F10)){
				//debug_= ! debug_;
			}
			if(IsKeyPressed(KeyboardKey.KEY_F11)){
				changecolors;
			}
			foreach(c;game.drawsort){
				draw(c,1,0);
			}
			
			//game.get.writeln;
			//DrawFPS(10,10);
		EndDrawing();
	}
	CloseWindow();
}