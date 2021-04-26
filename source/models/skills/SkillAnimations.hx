package models.skills;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import models.skills.Skill.Effect;
import ui.battle.SpriteAnimsLayer;
import ui.battle.character.CharacterSprite;
import utils.GameController;
import utils.GameUtils;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

typedef CustomPlayOptions =
{
	?touchBase:Bool,
	?screenAnim:Bool,
}

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
		return SpriteAnimsLayer.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 2);
	}

	public static function getFastHitAnim()
	{
		return SpriteAnimsLayer.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 4);
	}

	public static function getBlockAnim()
	{
		return SpriteAnimsLayer.createStandardAnim(AssetPaths.blockAnimBlue32x64x40__png, 32, 64, 40);
	}

	public static function getPowerUpAnim()
	{
		return SpriteAnimsLayer.createStandardAnim(AssetPaths.powerUpAnim2_50x50x36__png, 50, 50, 36);
	}

	public static function getSmallBlueExplosionAnim()
	{
		return SpriteAnimsLayer.createStandardAnim(AssetPaths.blueSmallExplosion100x100x70__png, 100, 100, 70);
	}

	/** Create a play that will run ONE bam animation group with 1 effect.
	 * The play is a function that, when run, adds an animation to the BAM and a sprite to the BSAL.
	 * To actually call the play, pass in the targets, owner and context.
	 * You can combine multiple "play" calls in a single skill's play to create complicated and chaining effects.
	**/
	public static function getCustomPlay(animSprite:FlxSprite, effect:Effect, effectFrame:Int = 0, ?sound:FlxSound, ?options:CustomPlayOptions)
	{
		if (options == null)
			options = {};

		var play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var effect = () ->
			{
				if (sound != null)
					sound.play();
				for (target in targets)
					effect(target, owner, context);
			};

			// if we're doing a screen animation, dont need to map sprites to the "others".
			// so just call addScreenAnim() and return early.
			if (options.screenAnim == true)
			{
				bsal.addScreenAnim(animSprite, effect, effectFrame);
				return;
			}

			var animSprites = new Array<FlxSprite>();
			var others = new Array<FlxSprite>();
			// clone the originally passed in animSprite so it can play on top of all targets (if there are multiple targets)
			// playing all these anims on the targets at once counts as a single BAM animation group
			for (target in targets)
			{
				// clone doesn't copy scale, so we have to re scale it :(
				var clone = animSprite.clone();
				clone.scale.set(3, 3);
				clone.updateHitbox();
				animSprites.push(clone);
				others.push(target.sprite);
			}

			if (options.touchBase == true)
				bsal.addOneShotAnimTouchBase(animSprites, others, effect, effectFrame);
			else
				bsal.addOneShotAnim(animSprites, others, effect, effectFrame);
		}
		return play;
	}

	/** Create a generic attack play. */
	public static function genericAttackPlay(damage:Int, ?customAnimSprite:FlxSprite, effectFrame:Int = 0, ?sound:FlxSound)
	{
		var animSprite:FlxSprite = customAnimSprite != null ? customAnimSprite : getHitAnim();
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			owner.dealDamageTo(damage, target, context);
		};
		return getCustomPlay(animSprite, effect, effectFrame, sound);
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

	/** This assumes the targets are getting the buff. Don't use alone if the target and the character getting the buff (e.g. owner) are different! */
	public static function genericBuffPlay(effect:Effect, ?customAnimSprite:FlxSprite, ?sound:FlxSound)
	{
		var animSprite = customAnimSprite != null ? customAnimSprite : getPowerUpAnim();
		var soundToPlay = sound != null ? sound : FlxG.sound.load(AssetPaths.powerup1__wav);
		return getCustomPlay(animSprite, effect, 0, soundToPlay, {touchBase: true});
	}

	/** Create a screenAnimSprite with SAL.createScreenAnim first. **/
	public static function screenAnimPlay(effect:Effect, screenAnimSprite:FlxSprite, effectFrame:Int = 0, ?sound:FlxSound)
	{
		return getCustomPlay(screenAnimSprite, effect, effectFrame, sound, {screenAnim: true});
	}
}
