package ui.battle.status.skillSpecific;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;

// Real usage is defined in onGainBlock
class HideBreakerStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('For the next $valAfter turn(s), ${owner.info.name} can\'t gain block.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = HIDEBREAKER;
		name = 'Hide Breaker';
		var desc = 'For the next $initialStacks turn(s), ${owner.info.name} can\'t gain block.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
