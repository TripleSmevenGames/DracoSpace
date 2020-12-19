package ui.battle;

/** Does something when turn starts or ends. Functions called by BattleManager. **/
interface ITurnable
{
	public function onPlayerStartTurn():Void;
	public function onPlayerEndTurn():Void;
	public function onEnemyStartTurn():Void;
	public function onEnemyEndTurn():Void;
}
