package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.CharacterInfo;
import ui.battle.character.CharacterSprite;
import ui.battle.win.SkillCard;
import ui.inventory.SkillCardBlank;
import ui.inventory.SkillCardLocked;

using utils.ViewUtils;

/** Not centered. Starts at left top of profile sprite. **/
class CharacterProfile2 extends FlxSpriteGroup
{
	public var char:CharacterInfo;
	public var skillCards:Array<SkillCard> = [];

	public function new(char:CharacterInfo)
	{
		super();

		this.char = char;

		var background = new FlxSprite();
		background.makeGraphic(64 * 3, 80 * 3, FlxColor.fromRGB(0, 0, 0, 100));
		add(background);

		var characterSprite = CharacterSprite.loadSpriteSheetInfo(char.spriteSheetInfo);
		characterSprite.centerSprite(background.getMidpoint().x, background.getMidpoint().y);
		add(characterSprite);
		characterSprite.animation.play('idle');

		var charName = new FlxText(0, 0, 0, char.name);
		charName.setFormat(Fonts.STANDARD_FONT, 24, FlxColor.YELLOW);
		charName.centerSprite(characterSprite.width / 2, 0);
		add(charName);

		var cursor = background.width * 1.5 + 16;
		var yPos = background.height / 2;

		// place skills after the character's image
		for (skill in char.skills)
		{
			var skillCard = new SkillCard(skill, NORMAL);
			skillCards.push(skillCard);

			skillCard.setPosition(cursor, yPos);
			add(skillCard);

			cursor += SkillCard.bodyWidth + 8;
		}

		// then place the blanks
		for (i in 0...char.numSkillSlots - char.skills.length)
		{
			var blank = new SkillCardBlank();
			blank.setPosition(cursor, yPos);
			add(blank);

			cursor += blank.width + 8;
		}

		// then place the locked slots
		for (i in 0...5 - char.numSkillSlots)
		{
			var locked = new SkillCardLocked();
			locked.setPosition(cursor, yPos);
			add(locked);

			cursor += locked.width + 8;
		}
	}
}
