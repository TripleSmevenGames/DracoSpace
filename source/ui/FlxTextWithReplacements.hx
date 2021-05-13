package ui;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import models.skills.Skill.SkillPointType;
import ui.battle.status.Status.StatusType;
import utils.ViewUtils;

using StringTools;

typedef FlxTextWithReplacementsOptions =
{
	?bodyWidth:Float,
	?fontSize:Int,
	?border:Bool,
	?centered:Bool,
	?lineHeightMultiplier:Float,
}

class FlxTextWithReplacements extends FlxSpriteGroup
{
	var xReplacement:Null<String> = null;
	var x2Replacement:Null<String> = null;
	var options:FlxTextWithReplacementsOptions;

	function getDefaults(options:FlxTextWithReplacementsOptions)
	{
		if (options.bodyWidth == null)
			options.bodyWidth = 200;
		if (options.fontSize == null)
			options.fontSize = 16;
		if (options.border == null)
			options.border = false;
		if (options.centered == null)
			options.centered = false;
		if (options.lineHeightMultiplier == null)
			options.lineHeightMultiplier = 1.2;
		return options;
	}

	// turn the word into flxText or sprite depending on what it is.
	function processWord(word:String, fontSize:Int = 16, border:Bool = false):FlxSprite
	{
		// ending punctuation like commas or periods mess things up. So lets first take it out, then add it back at the end.
		var punctuation = null;
		if (word.endsWith('.'))
			punctuation = '.';
		else if (word.endsWith(','))
			punctuation = ',';

		if (punctuation != null)
			word = word.substring(0, word.length - 1);

		// if the word is one of our skill types, return that skills type's icon.
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

		// replace $cd with a clock icon for indicating cooldown
		if (word == "$cd")
		{
			var sprite = new FlxSprite(0, 0, AssetPaths.cooldownIcon__png);
			sprite.scale.set(2, 2);
			sprite.updateHitbox();
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

		// add back the punctuation
		if (punctuation != null)
			textSprite.text += punctuation;

		if (border)
		{
			textSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE);
		}

		return textSprite;
	}

	/** Takes an input string, processes it, add add()'s the sprites in. **/
	public function processAndPlaceInput(input:String)
	{
		forEach((sprite:FlxSprite) -> remove(sprite));
		var text = input.split(' ');
		var cursor = new FlxPoint();
		var lineheight = options.fontSize * options.lineHeightMultiplier;

		for (word in text)
		{
			// turn the word into its correct replacement if needed.
			if (word == '\n')
			{
				cursor.x = 0;
				cursor.y += lineheight;
				continue;
			}
			var spriteToPlace = processWord(word, options.fontSize, options.border);
			// then, check if this sprite can fit at the current cursor (not centered).
			var canFit = cursor.x + spriteToPlace.width < options.bodyWidth;
			if (!canFit)
			{
				cursor.x = 0;
				cursor.y += lineheight;
			}
			spriteToPlace.setPosition(cursor.x, cursor.y);
			add(spriteToPlace);

			cursor.x += spriteToPlace.width + 2;
		}
		if (options.centered)
			centerText();
	}

	/** Doesnt center align the text, just shifts all of it over**/
	function centerText()
	{
		var shiftAmount = (options.bodyWidth - this.width) / 2;
		forEach((sprite:FlxSprite) ->
		{
			sprite.x += shiftAmount;
		});
	}

	/** Create a sprite group from string, which will replace certain things with custom sprites. NOT CENTERED. **/
	public function new(input:String, ?xReplacement:String, ?x2Replacement:String, options:FlxTextWithReplacementsOptions)
	{
		super();
		this.options = getDefaults(options);
		this.xReplacement = xReplacement;
		this.x2Replacement = x2Replacement;

		processAndPlaceInput(input);
	}
}
