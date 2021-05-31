package ui.battle;

import ui.battle.character.CharacterSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

/** Can be triggered at moments during a turn. **/
interface ITurnTriggerable
{
	public function onPlayerStartTurn(context:BattleContext):Void;
	public function onPlayerEndTurn(context:BattleContext):Void;
	public function onEnemyStartTurn(context:BattleContext):Void;
	public function onEnemyEndTurn(context:BattleContext):Void;
}
