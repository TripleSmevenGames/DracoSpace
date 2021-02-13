package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;

// Dodge usage is defined in CharacterSPrite's takeDamage.
class DodgeStatus extends DecayingStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = DODGE;
		name = 'Dodge';
		var desc = 'When this character would take damage, instead dodge it and lose 1 stack. Lose 1 stack at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
