package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.battle.CharacterSprite;

/** A sprite representing a skill during battle. This is not the Skill itself, but it should always have a reference to
	the Skill it represents. This should not exist outside the context of a battle.
	*
	* During battle, you should pretty much ALWAYS be interacting and modifying the SkillSprite, not the Skill itself.
 */
class SkillSprite extends FlxSpriteGroup
{
	public var skill:Skill;
	public var tile:FlxSprite;
	public var owner:CharacterSprite;

	// cooldown of x means the you must wait x turns before it can be used again.
	// cooldown of 0 means this skill can be used this turn.
	public var cooldownTimer(default, set):Int = 1;
	public var currentCharges(default, set):Int = 1;

	public var disabled(default, set):Bool;

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
		Happens if it goes on cooldown, or is disabled by an affect.
	**/
	public function set_disabled(val:Bool)
	{
		if (owner != null && owner.dead)
			this.disabled = true;

		if (val)
		{
			this.tile.color = FlxColor.GRAY;
			this.tile.alpha = .5;
		}
		else
		{
			this.tile.color = FlxColor.WHITE;
			this.tile.alpha = 1;
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

	public function runEffect(targets:Array<CharacterSprite>)
	{
		if (this.disabled)
			return;

		skill.effect(targets);
		this.currentCharges -= 1;
		this.cooldownTimer += skill.cooldown;
	}

	public function onNewRound()
	{
		this.cooldownTimer -= 1;
	}

	public function new(skill:Skill, owner:CharacterSprite)
	{
		super(0, 0);
		this.skill = skill;

		tile = new FlxSprite(0, 0, skill.spritePath);
		tile.scale.set(2, 2);
		tile.updateHitbox();
		add(tile);

		this.cooldownTimer = 0;
		this.currentCharges = skill.maxCharges;
		this.owner = owner;

		var tooltip = new Tooltip(skill.name, skill.desc);
		tooltip.centerAboveParent(tile);
		add(tooltip);

		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		FlxMouseEventManager.add(tile, null, null, null, null, null, null, false);
		tooltip.bindTo(tile);

		disabled = false;
	}
}
