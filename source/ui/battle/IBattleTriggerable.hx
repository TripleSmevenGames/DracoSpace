package ui.battle;

import models.CharacterInfo.CharacterType;
import models.cards.Card;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.SkillSprite;
import utils.battleManagerUtils.BattleContext;

/** Can be triggered when certain things happen in battle, in reference to the character that owns this thing.
 * For example, this thing might be a Status or an equipped Artifact.
 * If so, onTakeDamage is called when the character that owns this thing takes damage.
 * INHERITS from ITurnTriggerable
**/
interface IBattleTriggerable extends ITurnTriggerable
{
	/** dont modify damage here
	 * This is called BEFORE the character has taken damage.
	 * Val is the final damage the character will take after all modifiers before block is calculated.
	**/
	function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext):Void;

	function onTakeUnblockedDamage(damage:Int, dealer:CharacterSprite, context:BattleContext):Void;

	function onGainBlock(block:Int, context:BattleContext):Void;

	/** This is called BEFORE The skill's play() is called, but after the skill has been "counted" for skills played this turn. **/
	function onPlaySkill(skillSprite:SkillSprite, context:BattleContext):Void;

	/** This is called AFTER the skill's play is called. This may cause problems? **/
	function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext):Void;

	/** dont modify damage here.
	 * This is called BEFORE char.dealDamageTo() is called.
	**/
	function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext):Void;

	function onDead(context:BattleContext):Void;

	/** Called when any card (player or enemy) is drawn. Its called after card.resetForDraw() **/
	function onDrawCard(card:Card, type:CharacterType, context:BattleContext):Void;
}
