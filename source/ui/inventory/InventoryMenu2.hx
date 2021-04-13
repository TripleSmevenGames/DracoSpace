package ui.inventory;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import models.player.Player;
import ui.battle.win.SkillCard;

using utils.ViewUtils;

/** The menu that shows up when youre enter the inventory ss. NOT Centered. Place at 0, 0**/
class InventoryMenu2 extends FlxSpriteGroup
{
	static inline final PADDING = 32;

	var profiles:Array<CharacterProfile2> = [];
	var unequippedSkillsList:UnequippedSkillsList2;

	var equippedSkillCards:Array<SkillCard> = [];
	var unequippedSkillCards:Array<SkillCard> = [];

	var clickSound:FlxSound;
	var headerHeight:Float;

	function onEquippedSkillClick(skillCard:SkillCard)
	{
		for (char in Player.chars)
			char.unequipSkill(skillCard.skill);
		clickSound.play();
		refresh();
	}

	function onUnequippedSkillClick(skillCard:SkillCard)
	{
		// if the skill's not generic, just equip it to right character
		if (skillCard.skill.category != generic)
		{
			for (char in Player.chars)
			{
				if (char.category == skillCard.skill.category)
					char.equipSkill(skillCard.skill);
			}
		}
		else
		{
			// handle it
		}
		clickSound.play();
		refresh();
	}

	function setupSkillCardHandlers()
	{
		// first, organize all the skill tiles
		unequippedSkillCards = unequippedSkillsList.skillCards;
		equippedSkillCards = [];
		for (profile in profiles)
			equippedSkillCards = equippedSkillCards.concat(profile.skillCards);

		// then, give each the proper handlers.
		// if you click on an equipped skill tile, unequip it.
		// if you click on an unequipped tile, equip it if its char specific. Else the user has to click on the choice.
		for (skillCard in equippedSkillCards)
		{
			FlxMouseEventManager.setMouseClickCallback(skillCard, (_) -> onEquippedSkillClick(skillCard));
		}
		for (skillCard in unequippedSkillCards)
		{
			FlxMouseEventManager.setMouseClickCallback(skillCard, (_) -> onUnequippedSkillClick(skillCard));
		}
	}

	// maybe slow
	public function refresh()
	{
		forEach((sprite:FlxSprite) ->
		{
			remove(sprite);
			sprite.destroy();
		});

		profiles = [];
		for (i in 0...Player.chars.length)
		{
			var char = Player.chars[i];
			var profile = new CharacterProfile2(char);
			profiles.push(profile);
		}

		unequippedSkillsList = new UnequippedSkillsList2();

		// put the unequipped list at the bottom.
		unequippedSkillsList.setPosition(FlxG.width / 2, FlxG.height - (unequippedSkillsList.bodyHeight / 2) - 4);
		add(unequippedSkillsList);

		// then place the 2 profiles under the header
		// the profile height is funky, not sure why. Use the skill card's hardcoded height instead. It's pretty close.
		var cursor = headerHeight + 8;
		profiles[0].centerX(FlxG.width / 2);
		profiles[0].y = cursor;
		add(profiles[0]);

		cursor += SkillCard.bodyHeight + 8;
		profiles[1].centerX(FlxG.width / 2);
		profiles[1].y = cursor;
		add(profiles[1]);

		setupSkillCardHandlers();
	}

	public function new(headerHeight:Float)
	{
		super();
		this.clickSound = FlxG.sound.load(AssetPaths.pickCard1__wav);
		this.headerHeight = headerHeight;
		refresh();
	}
}
