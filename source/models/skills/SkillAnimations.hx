package models.skills;

import models.skills.Skill.Effect;
import ui.battle.character.CharacterSprite;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

/** Used as a helper to create "play" functions for skills. **/
class SkillAnimations
{
	/** Create a generic attack play. */
	public static function genericAttackPlay(damage:Int)
	{
		var play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var bsal = GameController.battleSpriteAnimsLayer;
			var animatedHit = bsal.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 2);
			var effect = () ->
			{
				for (target in targets)
					owner.dealDamageTo(damage, target, context);
			}
			for (target in targets)
				bsal.addOneShotAnim(animatedHit, target.x, target.y, effect, 0);
		}

		return play;
	}

	/** Create a generic block play. **/
	public static function genericBlockPlay(block:Int)
	{
		var play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var bsal = GameController.battleSpriteAnimsLayer;
			var animatedBlock = bsal.createStandardAnim(AssetPaths.blockAnimBlue32x64x40__png, 32, 64, 40);
			var effect = () ->
			{
				for (target in targets)
					target.currBlock += block;
			}
			for (target in targets)
				bsal.addOneShotAnim(animatedBlock, target.x, target.y, effect, 10);
		}
		return play;
	}
}
