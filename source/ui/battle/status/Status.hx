package ui.battle.status;

import flixel.group.FlxSpriteGroup;
import utils.BattleManager;
import utils.battleManagerUtils.BattleContext;

enum StatusType
{
	BURN;
	STATIC;
	COLD;
	ATTACK;
	TAUNT;
}

class Status extends FlxSpriteGroup implements ITurnTriggerable
{
	public var type:StatusType;
	public var name:String;
	public var icon:BattleIndicatorIcon;
	public var stacks(default, set):Int = 1;
	public var stackable:Bool = true;

	/** The character this status is on. **/
	public var owner:CharacterSprite;

	public function set_stacks(val:Int)
	{
		if (val <= 0)
		{
			val = 0;
			removeFromOwner();
		}

		if (stackable)
			icon.updateDisplay(Std.string(val));
		else
			icon.updateDisplay('');

		return stacks = val;
	}

	public function removeFromOwner()
	{
		owner.removeStatus(type);
	}

	// some of these functions are just dummies. The status classes need to override these.
	public function onPlayerStartTurn(context:BattleContext) {}

	public function onPlayerEndTurn(context:BattleContext) {}

	public function onEnemyStartTurn(context:BattleContext) {}

	public function onEnemyEndTurn(context:BattleContext) {}

	public function onTakeDamage(context:BattleContext) {}

	public function onTakeUnblockedDamage() {}

	public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext) {}

	/** Do something when this character deals damage to another.
		If you want to modify the damage dealt, return a new damage.
	**/
	public function onDealDamage(originalDamage:Int)
	{
		return originalDamage;
	}

	public function onDead(context:BattleContext) {}

	public function new(owner:CharacterSprite, icon:BattleIndicatorIcon, initialStacks:Int = 1)
	{
		super(0, 0);
		this.icon = icon;
		this.owner = owner;

		add(icon);
	}
}