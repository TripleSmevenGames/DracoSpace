package ui;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import models.skills.Skill.SkillPointType;
import ui.battle.status.Status.StatusType;
import utils.ViewUtils;

class FlxTextWithReplacements extends FlxSpriteGroup
{
	var fontSize:Int;
	var xReplacement:Null<String> = null;
	var x2Replacement:Null<String> = null;

	// turn the word into flxText or sprite depending on what it is.
	function processWord(word:String, fontSize:Int = 16, border:Bool = false):FlxSprite
	{
		if (word == 'POW' || word == 'AGI' || word == 'CON' || word == 'KNO' || word == 'WIS' || word == 'ANY')
		{
			var sprite = ViewUtils.getIconForType(SkillPointType.createByName(word));
			if (fontSize > 16)
			{
				sprite.scale.set(2, 2);
				sprite.updateHitbox();
			}
			return sprite;
		}

		// see if the word is a StatusType. If so, color it.
		try
		{
			var status = StatusType.createByName(word.toUpperCase());
			var textSprite = new FlxText(0, 0, 0, word);
			textSprite.setFormat(Fonts.STANDARD_FONT, fontSize);
			textSprite.color = ViewUtils.getColorForStatus(status);
			return textSprite;
		}
		catch (e) {} // no-op

		var textSprite = new FlxText(0, 0);
		textSprite.setFormat(Fonts.STANDARD_FONT, fontSize);
		// see if its an x or x2 value;
		if (word == "$x" || word == "%x")
			textSprite.text = this.xReplacement
		else if (word == "$x2" || word == "%x2")
			textSprite.text = this.x2Replacement;
		else
			textSprite.text = word;

		if (border)
		{
			textSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE);
		}

		return textSprite;
	}

	/** Create a sprite group from string, which will replace certain things with custom sprites. NOT CENTERED. **/
	public function new(width:Float = 100, fontSize:Int = 16, input:String, ?xReplacement:String, ?x2Replacement:String, ?border:Bool = false)
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
			var spriteToPlace = processWord(word, fontSize, border);
			// then, check if this sprite can fit at the current cursor (not centered).
			var canFit = cursor.x + spriteToPlace.width < width;
			if (!canFit)
			{
				cursor.x = 0;
				cursor.y += lineheight;
			}
			spriteToPlace.setPosition(cursor.x, cursor.y);
			add(spriteToPlace);

			cursor.x += spriteToPlace.width + 2;
		}
	}
}
