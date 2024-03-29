package ui.battle;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import managers.BattleAnimationManager.BattleAnimationGroupOptions;
import managers.BattleManager;
import managers.GameController;
import models.skills.Skill.Effect;
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

	/** Setup an animated sprite to be added to the BAM.
	 *
	 * This creates an animated sprite from a sheet, scales it, and adds a "play" animation.
	**/
	public static function createStandardAnim(assetPath:FlxGraphicAsset, width:Int, height:Int, numFrames:Int, skipFrames:Int = 1, ?frameRate:Int = FRAME_RATE)
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

		sprite.animation.add('play', frames, frameRate, false);
		return sprite;
	}

	public static function createScreenAnim(assetPath:FlxGraphicAsset, numFrames:Int)
	{
		return createStandardAnim(assetPath, 600, 400, numFrames);
	}

	/** Add an animated sprite to the BSAL and add its animation to the BAM. all animations will play when their turn comes.
	 *
	 * The sprites you passed in should have been setup by createStandardAnim. This and other similar functions should only be called by getCustomPlay()
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
			try
			{
				add(sprites[i]);
			}
			catch (e)
			{
				trace('sprite has x? ${sprites[i].x}');
				trace('this has x? ${this.x}');
				throw e;
			}
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

	/** should only be called by SkillAnimation.getCustomPlay() **/
	public function addScreenAnim(sprite:FlxSprite, effect:Void->Void, effectFrame:Int = 0)
	{
		var animations:Array<FlxAnimation> = [sprite.animation.getByName('play')];
		add(sprite);

		var bagOptions:BattleAnimationGroupOptions = {
			onCompleteAll: () ->
			{
				sprite.destroy();
				this.remove(sprite);
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
