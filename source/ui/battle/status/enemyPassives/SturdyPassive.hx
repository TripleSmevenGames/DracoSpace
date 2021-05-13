package ui.battle.status.enemyPassives;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

/** usage is defined in characterSprite's onTakeDamage**/
class SturdyPassive extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('This character takes $valAfter less damage from all sources.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = STURDY;
		name = 'Sturdy';
		var desc = 'This character takes $initialStacks less damage from all sources.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.sturdy__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
