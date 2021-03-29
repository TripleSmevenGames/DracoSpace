package ui.battle;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.TooltipLayer;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.GameController;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** A sprite representing a skill during battle. This is not the Skill itself, but it should always have a reference to
	the Skill it represents. This should not exist outside the context of a battle.
	*
	* During battle, you should pretty much ALWAYS be interacting and modifying the SkillSprite, not the Skill itself.
 */
class SkillSprite extends FlxSpriteGroup
{
	public var skill:Skill;
	public var tile:FlxSprite;
	public var cooldownCountdownSprite:FlxText;
	public var priority:Int = 0;
	public var owner:CharacterSprite;

	// cooldown of x means the you must wait x turns before it can be used again.
	// cooldown of 0 means this skill can be used this turn.
	public var cooldownTimer(default, set):Int = 1;
	public var currentCharges(default, set):Int = 1;
	public var disabled(default, set):Bool;

	public var mouseOverCallbacks:Array<FlxSprite->Void> = [];
	public var mouseOutCallbacks:Array<FlxSprite->Void> = [];

	public function set_cooldownTimer(val:Int)
	{
		if (val == 0) // refund charges on this skill when cooldown hits 0;
		{
			currentCharges += skill.chargesPerCD;
			if (currentCharges < skill.maxCharges) // and if there are still charges to restore, put the skill on cooldown again.
				return cooldownTimer = skill.cooldown;
		}

		if (val < 0)
			val = 0;

		this.cooldownCountdownSprite.text = Std.string(val);
		return cooldownTimer = val;
	}

	public function set_currentCharges(val:Int)
	{
		if (val > skill.maxCharges)
			val = skill.maxCharges;

		if (val < 0)
			val = 0;

		this.disabled = (val == 0);

		return currentCharges = val;
	}

	/** Disable this skill, greying it out and stopping all click handlers. 
		Happens if it goes on cooldown, is disabled by an affect, or owner dies
	**/
	public function set_disabled(val:Bool)
	{
		if (owner != null && owner.dead)
			this.disabled = true;

		if (val)
		{
			this.tile.color = FlxColor.GRAY;
			this.tile.alpha = .5;
			this.cooldownCountdownSprite.visible = true;
			this.cooldownCountdownSprite.text = Std.string(cooldownTimer);
		}
		else
		{
			this.tile.color = FlxColor.WHITE;
			this.tile.alpha = 1;
			this.cooldownCountdownSprite.visible = false;
		}
		return this.disabled = val;
	}

	/** Sets the click callback, which will fire when clicked if the skill is not disabled. **/
	public function setOnClick(onClick:SkillSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(tile, (_) ->
		{
			if (disabled)
				return;
			else
				onClick(this);
		});
	}

	public function addHoverCallback(over:FlxSprite->Void, out:FlxSprite->Void)
	{
		mouseOverCallbacks.push(over);
		mouseOutCallbacks.push(out);
	}

	public function play(targets:Array<CharacterSprite>, context:BattleContext)
	{
		if (this.disabled)
			return;

		skill.play(targets, this.owner, context);
		this.currentCharges -= 1;
		this.cooldownTimer += skill.cooldown;
	}

	public function onNewRound()
	{
		if (owner.hasStatus(STUN) == 0)
			this.cooldownTimer -= 1;
	}

	public function new(skill:Skill, owner:CharacterSprite)
	{
		super(0, 0);
		this.skill = skill;

		tile = new SkillTile(skill);
		add(tile);

		// setup the cooldown counter, which will appear on the tile when its on cooldown.
		cooldownCountdownSprite = new FlxText(0, 0, 0, '0');
		cooldownCountdownSprite.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG);
		cooldownCountdownSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0, 1);
		cooldownCountdownSprite.centerSprite();
		add(cooldownCountdownSprite);
		cooldownCountdownSprite.visible = false;

		this.cooldownTimer = 0;
		this.currentCharges = skill.maxCharges;
		this.owner = owner;
		this.priority = skill.priority;

		// setup the cost indicator under the tile.
		var costTextSprite = new FlxTextWithReplacements(80, 12, skill.getCostStringCompact());
		costTextSprite.centerSprite(0, tile.height / 2 + 8);
		add(costTextSprite);

		// setup the mouse events
		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		FlxMouseEventManager.add(tile, null, null, null, null, false, true, false);
		FlxMouseEventManager.setMouseOverCallback(tile, (sprite:FlxSprite) ->
		{
			for (callback in mouseOverCallbacks)
				callback(sprite);
		});
		FlxMouseEventManager.setMouseOutCallback(tile, (sprite:FlxSprite) ->
		{
			for (callback in mouseOutCallbacks)
				callback(sprite);
		});

		// setup the hover effect
		var darken = (_) -> tile.color = FlxColor.fromRGB(200, 200, 200);
		var undarken = (_) -> tile.color = FlxColor.WHITE;
		addHoverCallback(darken, undarken);

		// setup the tooltip (which is also a hover effect)
		GameController.battleTooltipLayer.createTooltipForSkill(this);

		disabled = false;
	}
}
