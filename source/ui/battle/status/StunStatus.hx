package ui.battle.status;

package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;

// stun usage is defined in skillSprite.
class StunStatus extends DecayingStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = TAUNT;
		name = 'Stun';
		var desc = 'At the start of turn, skill cooldowns don\'t count down. Lose 1 stack at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Taunt1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
