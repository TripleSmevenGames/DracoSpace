package ui.battle;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill.Effect;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** This is a sprite "layer" that will hold battle sprite animations. 
 *
 * Call createStandardAnim to create your animated sprite.
 * Then use addOneShotAnim to combine your animated sprite and your game effect.
 *
 * See functions in "SkillAnimations" for example usage.
**/
class SpriteAnimsLayer extends FlxSpriteGroup
{
	public static inline final FRAME_RATE = 30;

	/** Setup an animated sprite to be added to the BAM**/
	public function createStandardAnim(assetPath:FlxGraphicAsset, width:Int, height:Int, numFrames:Int, skipFrames:Int = 1)
	{
		var sprite = new FlxSprite(0, 0);
		sprite.loadGraphic(assetPath, true, width, height);
		sprite.scale.set(3, 3);
		sprite.updateHitbox();

		var frames = new Array<Int>();
		for (i in 0...numFrames)
		{
			if (i % skipFrames == 0)
				frames.push(i);
		}

		sprite.animation.add('play', frames, FRAME_RATE, false);
		return sprite;
	}

	/** Add an animated sprite to the BSAL and add its animation to the BAM. 
	 *
	 * The sprites you passed in should have been setup by createStandardAnim.
	 *
	 * Each animation is mapped ontop of its corresponding "other".
	**/
	public function addOneShotAnim(sprites:Array<FlxSprite>, others:Array<FlxSprite>, effect:Void->Void, effectFrame:Int = 0, touchBase:Bool = false)
	{
		var animations = new Array<FlxAnimation>();
		for (i in 0...sprites.length)
		{
			var center = others[i].getMidpoint();
			sprites[i].centerSprite(center.x, center.y);
			add(sprites[i]);
			animations.push(sprites[i].animation.getByName('play'));
		}
		var bagOptions:BattleAnimationGroupOptions = {
			onCompleteAll: () ->
			{
				for (sprite in sprites)
				{
					sprite.destroy();
					this.remove(sprite);
				}
			},
			effect: effect,
			effectFrame: effectFrame,
		}
		GameController.battleAnimationManager.addAnimations(animations, bagOptions);
	}

	public function addOneShotAnimTouchBase(sprites:Array<FlxSprite>, others:Array<FlxSprite>, effect:Void->Void, effectFrame:Int = 0)
	{
		var animations = new Array<FlxAnimation>();
		for (i in 0...sprites.length)
		{
			sprites[i].matchBottomCenter(others[i]);
			add(sprites[i]);
			animations.push(sprites[i].animation.getByName('play'));
		}
		var bagOptions:BattleAnimationGroupOptions = {
			onCompleteAll: () ->
			{
				for (sprite in sprites)
				{
					sprite.destroy();
					this.remove(sprite);
				}
			},
			effect: effect,
			effectFrame: effectFrame,
		}
		GameController.battleAnimationManager.addAnimations(animations, bagOptions);
	}

	public function new()
	{
		super(0, 0);
	}
}
