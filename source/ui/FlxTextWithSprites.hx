package ui;

/**
	class FlxTextWithSprites extends FlxTypedGroup<FlxSprite>{

	 public function new(parts:Array<Dynamic>){
		  for(part in parts){
			 if(Std.is(part, String)){
				//add a new FlxText to the group at the current cursor position
			 }else if (Std.is(part, FlxSprite)){
				//add the sprite at the current cursorposition, maybe scale it to the text height, etc
			 }
			 //update cursor position to be cursorPosition + the width of the sprite/text
		  }
	 }

	  }

	  if(cursor.x + newSpriteToAdd.width > maxWidth){
	cursor.x = 0;
	cursor.y += lineHeight;
	}
**/
