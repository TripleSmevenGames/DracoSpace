package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;

// Dodge usage is defined in CharacterSprite's takeDamage.
class DodgeStatus extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Completely evade the next $valAfter attack(s). Lose 1 stack per turn.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = DODGE;
		name = 'Dodge';
		var desc = 'Completely evade the next $initialStacks attack(s). Lose 1 stack per turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
