package ui.battle.status;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;

// Exposed usage is defined in set_block somewhere
class ExposedStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('For the next $valAfter turn(s), ${owner.info.name} gains 50% less Block.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = EXPOSED;
		name = 'Exposed';
		var desc = 'For the next $initialStacks turn(s), ${owner.info.name} gains 50% less Block.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
