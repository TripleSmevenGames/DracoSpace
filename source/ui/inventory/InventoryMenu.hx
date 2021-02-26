package ui.inventory;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import models.player.Player;

using utils.ViewUtils;

/** The menu that shows up when youre enter the inventory ss. Centered.**/
class InventoryMenu extends FlxSpriteGroup
{
	static inline final PADDING = 32;

	var profiles:Array<CharacterProfile> = [];
	var unequippedSkillsList:UnequippedSkillsList;

	var equippedSkillTiles:Array<SkillTile> = [];
	var unequippedSkillTiles:Array<SkillTile> = [];

	function onEquippedSkillClick(skillTile:SkillTile)
	{
		for (char in Player.chars)
			char.unequipSkill(skillTile.skill);
	}

	function onUnequippedSkillClick(skillTile:SkillTile)
	{
		// if the skill's not generic, just equip it to right character
		if (skillTile.skill.category != generic)
		{
			for (char in Player.chars)
			{
				if (char.category == skillTile.skill.category)
					char.equipSkill(skillTile.skill);
			}
		}
		else
		{
			// handle it
		}
	}

	function setupSkillTileHandlers()
	{
		// first, organize all the skill tiles
		unequippedSkillTiles = unequippedSkillsList.skillTiles;
		equippedSkillTiles = [];
		for (profile in profiles)
			equippedSkillTiles = equippedSkillTiles.concat(profile.skillTiles);

		// then, give each the proper handlers.
		// if you click on an equipped skill tile, unequip it.
		// if you click on an unequipped tile, equip it if its char specific. Else the user has to click on the choice.
		for (skillTile in equippedSkillTiles)
		{
			skillTile.addScaledToMouseManager();
			FlxMouseEventManager.setMouseClickCallback(skillTile, (_) ->
			{
				onEquippedSkillClick(skillTile);
				refresh();
			});
		}
		for (skillTile in unequippedSkillTiles)
		{
			skillTile.addScaledToMouseManager();
			FlxMouseEventManager.setMouseClickCallback(skillTile, (_) ->
			{
				onUnequippedSkillClick(skillTile);
				refresh();
			});
		}
	}

	public function refresh()
	{
		forEach((sprite:FlxSprite) ->
		{
			remove(sprite);
			sprite.destroy();
		});

		var profileHeight = 0.0;
		profiles = [];
		for (i in 0...Player.chars.length)
		{
			var char = Player.chars[i];
			var profile = new CharacterProfile(char);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, Player.chars.length, profile.width, PADDING);
			profile.setPosition(xPos, 0);
			add(profile);
			profiles.push(profile);

			profileHeight = profile.height;
		}

		unequippedSkillsList = new UnequippedSkillsList();
		unequippedSkillsList.setPosition(0, profileHeight + unequippedSkillsList.height);
		add(unequippedSkillsList);

		setupSkillTileHandlers();
	}

	public function new()
	{
		super();
		refresh();
	}
}
