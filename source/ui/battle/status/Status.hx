package ui.battle.status;

import flixel.group.FlxSpriteGroup;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.battleManagerUtils.BattleContext;

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
	EXHAUST;
	EXPOSED;
	LASTBREATH;
	DYINGWISH;
	CUNNING;
	SIPHON;
	PETALARMOR;
	PETALSPIKES;
	STURDY;
	UNSTABLE;
	PLUSDRAW;
	MINUSDRAW;
}

class Status extends FlxSpriteGroup implements ITurnTriggerable
{
	public var type:StatusType;
	public var name:String;
	public var icon:IndicatorIcon;
	public var stacks(default, set):Int = 1;
	public var stackable:Bool = true;

	/** The character this status is on. **/
	public var owner:CharacterSprite;

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

	// some of these functions are just dummies. The status classes need to override these to provide functionality.
	public function onPlayerStartTurn(context:BattleContext) {}

	public function onPlayerEndTurn(context:BattleContext) {}

	public function onEnemyStartTurn(context:BattleContext) {}

	public function onEnemyEndTurn(context:BattleContext) {}

	/** dont modify damage here
		*This is called AFTER the character has taken damage.
	**/
	public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext) {}

	public function onTakeUnblockedDamage() {}

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

		add(icon);
	}
}
