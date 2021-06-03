package ui.battle;

import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

/** Can be triggered when certain things happen in battle **/
interface IBattleTriggerable extends ITurnTriggerable
{
	/** dont modify damage here
	 * This is called BEFORE the character has taken damage.
	**/
	function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext):Void;

	function onTakeUnblockedDamage(damage:Int, dealer:CharacterSprite, context:BattleContext):Void;

	/** This is called BEFORE The skill's play() is called, but after the skill has been "counted" for skills played this turn. **/
	function onPlaySkill(skillSprite:SkillSprite, context:BattleContext):Void;

	/** This is called AFTER the skill's play is called. This may cause problems? **/
	function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext):Void;

	/** dont modify damage here.
	 * This is called BEFORE char.dealDamageTo() is called.
	**/
	function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext):Void;

	function onDead(context:BattleContext):Void;
}
