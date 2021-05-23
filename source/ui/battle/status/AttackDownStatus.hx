package ui.battle.status;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

/** usage is defined in characterSprite's dealDamage**/
class AttackDownStatus extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s skills deal $valAfter less damage');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = ATTACKDOWN;
		name = 'Attack Down';
		var desc = '${owner.info.name}\'s skills deal $initialStacks less damage.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.AttackDown__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
