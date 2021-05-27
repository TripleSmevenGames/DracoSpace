package ui.battle.status;

import managers.BattleManager;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

// stun usage is defined in skillSprite/status display.
class StunStatus extends DebuffStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = TAUNT;
		name = 'Stun';
		var desc = 'All skills are disabled this turn. Lose 1 stack at the end of turn.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Taunt1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
