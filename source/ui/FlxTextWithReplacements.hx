package ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import models.skills.Skill.SkillPointType;
import ui.battle.status.Status.StatusType;
import utils.ViewUtils;

class FlxTextWithSprites extends FlxSpriteGroup
{
	var fontSize:Int;
	var xReplacement:Null<String> = null;
	var x2Replacement:Null<String> = null;

	// turn the word into flxText or sprite depending on what it is.
	function processWord(word:String, fontSize:Int = 16):FlxSprite
	{
		if (word == 'POW' || word == 'AGI' || word == 'CON' || word == 'KNO' || word == 'WIS' || word == 'ANY')
			return ViewUtils.getIconForType(SkillPointType.createByName(word));

		// see if the word is a StatusType. If so, color it.
		try
		{
			var status = StatusType.createByName(word.toUpperCase());
			var textSprite = new FlxText(0, 0, 0, word, fontSize);
			textSprite.color = ViewUtils.getColorForStatus(status);
			return textSprite;
		}
		catch (e) {} // no-op

		// see if its an x or x2 value;
		if (word == "$x" || word == "%x")
			return new FlxText(0, 0, 0, this.xReplacement, fontSize);

		if (word == "$x2" || word == "%x2")
			return new FlxText(0, 0, 0, this.x2Replacement, fontSize);

		return new FlxText(0, 0, 0, word, fontSize);
	}

	/** Create a sprite group from string, which will replace certain things with custom sprites. **/
	public function new(width:Int = 100, fontSize:Int = 16, input:String, ?xReplacement:String, ?x2Replacement:String)
	{
		super();
		this.fontSize = fontSize;
		this.xReplacement = xReplacement;
		this.x2Replacement = x2Replacement;

		var text = input.split(' ');
		var cursor = new FlxPoint();
		var lineheight = fontSize * 1.5;

		for (word in text)
		{
			// turn the word into its correct replacement if needed.
			var spriteToPlace = processWord(word);
			// then, check if this sprite can fit at the current cursor (not centered).
			var canFit = cursor.x + spriteToPlace.width < width;
			if (!canFit)
			{
				cursor.x = 0;
				cursor.y += lineheight;
			}
			spriteToPlace.setPosition(cursor.x, cursor.y);
			add(spriteToPlace);

			cursor.x = spriteToPlace.width;
		}
	}
}
