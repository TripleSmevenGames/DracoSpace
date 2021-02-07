package models.skills;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import models.skills.Skill.Effect;
import ui.battle.character.CharacterSprite;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** Used as a helper to create "play" functions for skills. **/
class SkillAnimations
{
	static var bsal = GameController.battleSpriteAnimsLayer;

	public static function refreshBsal()
	{
		bsal = GameController.battleSpriteAnimsLayer;
	}

	public static function getHitAnim()
	{
		return bsal.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 2);
	}

	public static function getFastHitAnim()
	{
		return bsal.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 4);
	}

	public static function getBlockAnim()
	{
		return bsal.createStandardAnim(AssetPaths.blockAnimBlue32x64x40__png, 32, 64, 40);
	}

	public static function getPowerUpAnim()
	{
		return bsal.createStandardAnim(AssetPaths.powerUpAnim2_50x50x36__png, 50, 50, 36);
	}

	/** Create a play that will run ONE bam animation group with 1 effect. **/
	public static function getCustomPlay(animSprite:FlxSprite, effect:Effect, effectFrame:Int = 0, ?sound:FlxSound, touchBase = false)
	{
		var play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var effect = () ->
			{
				if (sound != null)
					sound.play();
				for (target in targets)
					effect(target, owner, context);
			};

			var animSprites = new Array<FlxSprite>();
			var others = new Array<FlxSprite>();
			for (target in targets)
			{
				// clone doesn't copy scale, so we have to re scale it :(
				var clone = animSprite.clone();
				clone.scale.set(3, 3);
				clone.updateHitbox();
				animSprites.push(clone);
				others.push(target.sprite);
			}

			if (touchBase)
				bsal.addOneShotAnimTouchBase(animSprites, others, effect, effectFrame);
			else
				bsal.addOneShotAnim(animSprites, others, effect, effectFrame);
		}
		return play;
	}

	/** Create a generic attack play. */
	public static function genericAttackPlay(damage:Int)
	{
		var animSprite = getHitAnim();
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			owner.dealDamageTo(damage, target, context);
		}
		return getCustomPlay(animSprite, effect);
	}

	/** Create a generic block play. **/
	public static function genericBlockPlay(block:Int)
	{
		var animSprite = getBlockAnim();
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			target.currBlock += block;
		}
		var effectFrame = 10;
		var sound = FlxG.sound.load(AssetPaths.gainBlock1__wav);
		return getCustomPlay(animSprite, effect, effectFrame, sound);
	}

	/** This assumes the targets are getting the buff. Don't use if the target and the character getting the buff (e.g. owner) are different! */
	public static function genericBuffPlay(effect:Effect)
	{
		var animSprite = getPowerUpAnim();
		var sound = FlxG.sound.load(AssetPaths.powerup1__wav);
		return getCustomPlay(animSprite, effect, 0, sound, true);
	}
}
