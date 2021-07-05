package ui.battle.status;

import flixel.group.FlxSpriteGroup;
import managers.BattleManager;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;
import ui.battle.combatUI.SkillSprite;

enum StatusType
{
	BURN;
	STATIC;
	COLD;
	ATTACK;
	ATTACKDOWN;
	TAUNT;
	COUNTER;
	DODGE;
	STUN;
	EXPOSED;
	LASTBREATH;
	DYINGWISH;
	HAUNT;
	CUNNING;
	SIPHON;
	PETALARMOR;
	PETALSPIKES;
	STURDY;
	UNSTABLE;
	PLUSDRAW;
	MINUSDRAW;
	WOUNDED;
	WEAK;
	REGENERATE;
}

class Status extends FlxSpriteGroup implements IBattleTriggerable
{
	public var type:StatusType;
	public var name:String;

	/** The indicator icon which is the main body of the Status when it shows up under the character's hp bar.
	 * It holds the status's name and description inside its tooltip.
	**/
	public var icon:IndicatorIcon;

	/** Some statuses may have stacks. Every active status technically has at least 1 stack, but if the status doesn't 
	 * stacks relevant to its mechanic, don't show the stacks on the icon.
	**/
	public var stacks(default, set):Int = 1;

	public var stackable:Bool = true;

	/** The character this status is on. **/
	public var owner:CharacterSprite;

	/** Remember if this status's tooltip was registered, that way we dont register the tooltip again by accident. 
	 * Because if we do, we'll probably cause a memory leak.
	**/
	var isTooltipRegistered:Bool = false;

	public function set_stacks(val:Int)
	{
		var valBefore = stacks;
		if (val <= 0)
		{
			val = 0;
			removeFromOwner();
		}

		if (stackable)
			icon.updateDisplay(Std.string(val));
		else
			icon.updateDisplay('');

		onSetStacks(valBefore, val);

		return stacks = val;
	}

	public function removeFromOwner()
	{
		owner.removeStatus(type);
	}

	public function updateTooltip(val:String)
	{
		icon.updateTooltipDesc(val);
	}

	/** Registers the icon's tooltip. **/
	public function registerTooltip()
	{
		if (isTooltipRegistered || icon == null)
			return;

		icon.registerTooltip();
		isTooltipRegistered = true;
	}

	// some of these functions are just dummies. The status classes need to override these to provide functionality.
	public function onPlayerStartTurn(context:BattleContext) {}

	public function onPlayerEndTurn(context:BattleContext) {}

	public function onEnemyStartTurn(context:BattleContext) {}

	public function onEnemyEndTurn(context:BattleContext) {}

	/** dont modify damage here
	 * This is called BEFORE the character has taken damage.
	**/
	public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext) {}

	public function onTakeUnblockedDamage(damage:Int, dealer:CharacterSprite, context:BattleContext) {}

	/** This is called BEFORE The skill's play() is called, but after the skill has been "counted" for skills played this turn. **/
	public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext) {}

	public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext) {}

	/** dont modify damage here.
	 * This is called BEFORE char.dealDamageTo() is called.
	**/
	public function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext) {}

	public function onDead(context:BattleContext) {}

	/** Override this to do something when the stack changes, like update the tooltip for example. **/
	public function onSetStacks(valBefore:Int, valAfter:Int) {}

	public function new(owner:CharacterSprite, icon:IndicatorIcon, initialStacks:Int = 1)
	{
		super(0, 0);
		this.icon = icon;
		this.owner = owner;
		this.stacks = initialStacks;

		add(icon);
	}
}
