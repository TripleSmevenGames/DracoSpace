package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

class AttackStatus extends Status
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = ATTACK;
		name = 'Attack';
		var desc = 'This character\'s skills deal X more damage.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Attack1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
