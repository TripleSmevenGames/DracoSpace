package ui.battle.character;

import flixel.group.FlxSpriteGroup;
import haxe.Exception;
import ui.battle.ITurnTriggerable;
import ui.battle.status.*;
import ui.battle.status.Status;
import ui.battle.status.enemyPassives.*;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class CharacterStatusDisplay extends FlxSpriteGroup implements ITurnTriggerable
{
	var statuses:Array<Status> = [];
	var owner:CharacterSprite;

	/** Position the status icons correctly based on how many there are. Assumes they are all added.
		Centered on the display's 0, 0;
	**/
	function renderStatuses()
	{
		for (i in 0...statuses.length)
		{
			var status = statuses[i];
			remove(status); // remove the status so that we can set its local coords.
			status.x = ViewUtils.getXCoordForCenteringLR(i, statuses.length, status.width - 4);
			status.y = 0;
			add(status);
			status.registerTooltip();
		}
	}

	function removeStatusByIndex(index:Int)
	{
		var status = statuses[index];
		statuses.splice(index, 1);
		remove(status);
		status.destroy();

		renderStatuses();
	}

	/** Returns the number of stacks of the status, or 0 if it doesn't have the status. **/
	public function getStatus(type:StatusType):Int
	{
		for (status in statuses)
		{
			if (status.type == type)
			{
				if (status.stacks == 0)
					trace('getStatus returned a ${status.name} status with 0 stacks');

				return status.stacks;
			}
		}
		return 0;
	}

	public function addStatusByType(type:StatusType, stacks:Int = 1)
	{
		if (stacks == 0)
			return;

		// first, if this status already exists, just add to the stacks of the existing status.
		for (status in statuses)
		{
			if (status.type == type)
			{
				status.stacks += stacks;
				return;
			}
		}

		// if not, then add it as a new status.
		var status = StatusMap.map.get(type)(this.owner);
		if (status != null)
		{
			status.stacks = stacks;
			statuses.push(status);

			// if this character was just stunned, recheck the disabled of the char's skill sprites
			if (type == STUN)
			{
				owner.checkDisabled();
			}
		}

		renderStatuses();
	}

	/** Removes a status from the list. Also returns how many stacks it had. Something wrong if this returns 0. **/
	public function removeStatusByType(type:StatusType)
	{
		var retVal = 0;
		for (i in 0...statuses.length)
		{
			var status = statuses[i];
			if (status != null && status.type == type)
			{
				retVal = status.stacks;
				removeStatusByIndex(i);
			}
		}
		if (retVal == 0)
			trace('something wrong, getting ${type.getName()} returned 0 stacks');

		return retVal;
	}

	public function removeStacks(type:StatusType, val:Int = 1)
	{
		for (i in 0...statuses.length)
		{
			var status = statuses[i];
			if (status != null && status.type == type)
			{
				status.stacks -= val;
				return;
			}
		}
		trace('Tried to remove ${val} stacks from non-existant ${type.getName()}');
	}

	public function removeAllStatuses()
	{
		this.statuses = [];
	}

	public function onPlayerStartTurn(context:BattleContext)
	{
		for (status in statuses)
			status.onPlayerStartTurn(context);
	}

	public function onPlayerEndTurn(context:BattleContext)
	{
		for (status in statuses)
			status.onPlayerEndTurn(context);
	}

	public function onEnemyStartTurn(context:BattleContext)
	{
		for (status in statuses)
			status.onEnemyStartTurn(context);
	}

	public function onEnemyEndTurn(context:BattleContext)
	{
		for (status in statuses)
			status.onEnemyEndTurn(context);
	}

	public function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext)
	{
		for (status in statuses)
			status.onDealDamage(damage, target, context);
	}

	public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		for (status in statuses)
		{
			status.onTakeDamage(damage, dealer, context);
		}
	}

	public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		for (status in statuses)
			status.onPlaySkill(skillSprite, context);
	}

	public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		for (status in statuses)
			status.onAnyPlaySkill(skillSprite, context);
	}

	public function onDead(context:BattleContext)
	{
		for (status in statuses)
			status.onDead(context);
	}

	public function new(owner:CharacterSprite)
	{
		super(0, 0);
		this.owner = owner;
	}
}
