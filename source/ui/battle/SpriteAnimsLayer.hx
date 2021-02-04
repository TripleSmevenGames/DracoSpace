package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill.Effect;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

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

	public function addSprite(sprite:FlxSprite, x:Float = 0, y:Float = 0)
	{
		ViewUtils.centerSprite(sprite, x, y);
		add(sprite);
	}

	/** Add an animated sprite to the BSAL and add its animation to the BAM. 
	 *
	 * The sprite you passed in should have been setup by createStandardAnim.
	**/
	public function addOneShotAnim(sprite:FlxSprite, x:Float, y:Float, effect:Void->Void, effectFrame:Int = 0)
	{
		this.addSprite(sprite, x, y);
		var animation = sprite.animation.getByName('play');
		var bagOptions:BattleAnimationGroupOptions = {
			onCompleteAll: () ->
			{
				sprite.destroy();
				this.remove(sprite);
			},
			effect: effect,
			effectFrame: effectFrame,
		}
		GameController.battleAnimationManager.addAnimations([animation], bagOptions);
	}

	public function new()
	{
		super(0, 0);
	}
}
