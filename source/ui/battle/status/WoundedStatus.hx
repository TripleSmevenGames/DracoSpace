package ui.battle.status;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

/** usage is defined in characterSprite's dealDamage**/
class WoundedStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s takes 50% more damage from enemy skills for $valAfter turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = WOUNDED;
		name = 'Wounded';
		var desc = '${owner.info.name}\'s takes more 50% damage from enemy skills for $initialStacks turn(s).';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.AttackDown__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
