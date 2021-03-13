package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.CharacterInfo;
import ui.battle.win.SkillCard;
import ui.battle.win.SkillCardBlank;

using utils.ViewUtils;

/** Not centered.**/
class CharacterProfile2 extends FlxSpriteGroup
{
	public var char:CharacterInfo;
	public var skillCards:Array<SkillCard> = [];

	public function new(char:CharacterInfo)
	{
		super();

		this.char = char;

		var background = new FlxSprite();
		background.makeGraphic(64 * 3, 80 * 3, FlxColor.fromRGB(0, 0, 0, 128));
		add(background);

		var characterSprite = new FlxSprite(0, 0, char.spritePath);
		characterSprite.scale3x();
		characterSprite.centerSprite(background.getMidpoint().x, background.getMidpoint().y);
		add(characterSprite);

		var charName = new FlxText(0, 0, 0, char.name);
		charName.setFormat(Fonts.STANDARD_FONT, 24, FlxColor.YELLOW);
		charName.centerSprite(characterSprite.width / 2, 0);
		add(charName);

		var cursor = background.width * 1.5 + 8;
		var yPos = background.height / 2;

		// place skills after the character's image
		for (skill in char.skills)
		{
			var skillCard = new SkillCard(skill, true);
			skillCards.push(skillCard);

			skillCard.setPosition(cursor, yPos);
			add(skillCard);

			cursor += SkillCard.bodyWidth + 8;
		}

		// then place the blanks
		for (i in 0...6 - char.skills.length)
		{
			var blank = new SkillCardBlank();
			blank.setPosition(cursor, yPos);
			add(blank);

			cursor += blank.width + 8;
		}
	}
}
