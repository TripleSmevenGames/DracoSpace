package ui.inventory.equipmentMenu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxSound;
import models.player.Player;
import ui.artifact.ArtifactTile;
import ui.artifact.ArtifactTileInv;
import ui.battle.IndicatorIcon;
import ui.inventory.equipmentMenu.DragLayer.DropZone;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** The character equipment menu. Equip skills and items. NOT Centered. Place at 0, 0**/
class EquipmentMenu extends FlxSpriteGroup
{
	var profiles:Array<CharacterProfile3> = [];
	var unequippedSkillsList:UnequippedSkillsList3;
	var unequippedArtifactsList:UnequippedArtifactsList;
	var infoIcon:IndicatorIcon;

	var equippedSkillTiles:Array<SkillTile> = [];
	var unequippedSkillTiles:Array<SkillTile> = [];
	var unequippedArtifactTiles:Array<ArtifactTile> = [];

	var dragLayer:DragLayer;

	var clickSound:FlxSound;
	var headerHeight:Float;

	function onEquippedSkillClick(skillTile:SkillTile)
	{
		for (char in Player.chars)
			char.unequipSkill(skillTile.skill);
		clickSound.play();
		refresh();
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
		clickSound.play();
		refresh();
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
			FlxMouseEventManager.setMouseClickCallback(skillTile, (_) -> onEquippedSkillClick(skillTile));
		}
		for (skillTile in unequippedSkillTiles)
		{
			FlxMouseEventManager.setMouseClickCallback(skillTile, (_) -> onUnequippedSkillClick(skillTile));
		}
	}

	/** Make sure this is called after the unequippedList components are rendered. **/
	function setupDragLayer()
	{
		// setup all the draggales
		var draggables = new Array<FlxSprite>();
		for (artifactTile in unequippedArtifactsList.artifactTiles)
			draggables.push(artifactTile);
		for (profile in profiles)
		{
			for (artifactTile in profile.artifactTiles)
				draggables.push(artifactTile);
		}

		// get the dropzones from the char profiles
		var dropZones = new Array<DropZone>();
		for (profile in profiles)
			dropZones.push(profile.dropZone);
		dropZones.push(unequippedArtifactsList.dropZone);

		// remove the previous dragLayer if exists
		if (dragLayer != null)
			remove(this.dragLayer);

		this.dragLayer = new DragLayer(draggables, dropZones);
		add(this.dragLayer);
	}

	// maybe slow? Lots of rerendering.
	// Could maybe save CPU by saving all "tiles" and just rearranging them accordingly,
	// instead of recreating them according to the Player state every time.
	// call this when the Player's data changes, so the view can reflect the current state.
	public function refresh()
	{
		for (profile in profiles)
			profile.refresh();

		unequippedSkillsList.refresh();
		unequippedArtifactsList.refresh();

		setupSkillTileHandlers();
		setupDragLayer();
	}

	public function new(headerHeight:Float)
	{
		super();
		this.clickSound = FlxG.sound.load(AssetPaths.pickCard1__wav);
		this.headerHeight = headerHeight;

		// make the 2 character profiles first first.
		profiles = [];
		for (i in 0...Player.chars.length)
		{
			var char = Player.chars[i];

			// this function runs when a tile (skill or artifact) is dragged onto the profile's DropZone sprite.
			var onDrop = (sprite:FlxSprite) ->
			{
				if (Std.isOfType(sprite, ArtifactTileInv))
				{
					var casted:ArtifactTileInv = cast(sprite, ArtifactTileInv);
					// equipArtifact already handles taking the artifact out of the Player's unequippedArtifact array.
					char.equipArtifact(casted.artifact);
					refresh();
				}
			}
			var profile = new CharacterProfile3(char, onDrop);
			profiles.push(profile);
		}

		unequippedSkillsList = new UnequippedSkillsList3();

		// this function runs when a tile (skill or artifact) is dragged onto the list's DropZone sprite.
		var unequippedArtifactonDrop = (sprite:FlxSprite) ->
		{
			if (Std.isOfType(sprite, ArtifactTileInv))
			{
				var casted:ArtifactTileInv = cast(sprite, ArtifactTileInv);
				var owner = casted.artifact.ownerInfo;
				if (owner != null)
					owner.unequipArtifact(casted.artifact);

				refresh();
			}
		}
		unequippedArtifactsList = new UnequippedArtifactsList(unequippedArtifactonDrop);

		// put the two profiles side by side under the header, in the middle of the screen.
		// then put the unequipped list under it.
		// profiles are not centered at all. The unequipped lists are centered on its body.
		var centerX = FlxG.width / 2;
		profiles[0].setPosition(centerX - profiles[0].width - 4, headerHeight + 32);
		add(profiles[0]);
		profiles[1].setPosition(centerX + 4, headerHeight + 16);
		add(profiles[1]);

		var unequippedY = profiles[0].y + profiles[0].height + unequippedSkillsList.bodyHeight / 2 + 60;
		unequippedSkillsList.setPosition(centerX, unequippedY);
		add(unequippedSkillsList);

		unequippedY += unequippedSkillsList.height + 16;
		unequippedArtifactsList.setPosition(centerX, unequippedY);
		add(unequippedArtifactsList);

		// small help tooltip icon in the corner.
		var infoText = 'Click on skills to equip or unequip them on your characters. '
			+ 'Only equipped skills can be used during battle. Most skills, but not all, are character-specific.';
		this.infoIcon = IndicatorIcon.createInfoIndicator('Party Skill Equipment', infoText);
		infoIcon.setPosition(FlxG.width - 200, FlxG.height - 250);
		add(infoIcon);

		infoIcon.registerTooltip();

		setupSkillTileHandlers();

		setupDragLayer();
	}
}
