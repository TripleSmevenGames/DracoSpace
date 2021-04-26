package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

/** usage is defined in characterSprite's dealDamage**/
class AttackStatus extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('This character\'s skills deal $valAfter more damage');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = ATTACK;
		name = 'Attack';
		var desc = 'This character\'s skills deal $initialStacks more damage.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Attack1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
