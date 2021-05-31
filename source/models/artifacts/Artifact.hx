package models.artifacts;

import Castle.SkillData_skills_rarity as Rarity;
import ui.battle.IBattleTriggerable;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

/** Represents an equipable item on a player character. 
 * Under the hood, it is very similar to a Status object. The main difference is that
 * A status is an FlxSprite because it only exists in battle. An artifact exists outside of battle,
 * so it needs an underlying model to represent it outside of battle. When a battle starts, the equipped artifacts will be
 * used to create the ArtifactSprite.
**/
class Artifact implements IBattleTriggerable
{
	public var name:String;
	public var desc:String;
	public var stacks:Null<Int>;
	public var rarity:Rarity;
	public var assetPath:String;

	/** a pointer to the characterSprite owner, which only exists during battle. Make sure to set this up before battle, and clean this up after battle. **/
	public var owner:Null<CharacterSprite>;

	/** a pointer to the owner's characterInfo, which still exists after battle. 
	 * When you are equipping or unequipping this, you must update the ownerInfo.
	**/
	public var ownerInfo:Null<CharacterInfo>;

	// some of these functions are just dummies. The artifact child classes need to override these to provide functionality.
	public function onPlayerStartTurn(context:BattleContext) {}

	public function onPlayerEndTurn(context:BattleContext) {}

	public function onEnemyStartTurn(context:BattleContext) {}

	public function onEnemyEndTurn(context:BattleContext) {}

	/** dont modify damage here
	 * This is called AFTER the character has taken damage.
	**/
	public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext) {}

	public function onTakeUnblockedDamage(damage:Int, dealer:CharacterSprite, context:BattleContext) {}

	/** This is called BEFORE The skill's play() is called, but after the skill has been "counted" for skills played this turn. **/
	public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext) {}

	public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext) {}

	/** dont modify damage here.
	 * This is called BEFORE char.dealDamageTo() is called.
	**/
	public function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext) {}

	public function onDead(context:BattleContext) {}

	/** Override this to do something when the stack changes, like update the tooltip for example. **/
	public function onSetStacks(valBefore:Int, valAfter:Int) {}

	public function new(name:String, desc:String, assetPath:String, ?rarity:Rarity)
	{
		this.name = name;
		this.assetPath = assetPath;
		this.rarity = rarity != null ? rarity : COMMON;
	}
}
