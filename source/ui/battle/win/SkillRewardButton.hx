package ui.battle.win;

import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import models.player.Player;
import openfl.geom.Rectangle;
import utils.ViewUtils;
import utils.battleManagerUtils.RewardHelper;

using utils.ViewUtils;

/** Button that opens up a subscreen showing 3 skills. The user clicks one to claim it */
class SkillRewardButton extends FlxSpriteGroup
{
	var button:FlxUIButton;

	static inline final initialString = 'LEVEL UP, CLAIM SKILL REWARD';
	static inline final claimedString = 'REWARD CLAIMED';

	var clicked:Bool;
	var subscreen:FlxSprite;

	function new(width:Int = 100, height:Int = 32, onClaim:Void->Void)
	{
		super();
		clicked = false;
		// make sure to add the subscreen after the button, so it is over top it.
		this.subscreen = new SkillRewardsSubScreen(onClaim);

		var onClick = () ->
		{
			if (clicked)
				return;

			subscreen.revive();
			this.button.label.text = claimedString;
			this.button.statusAnimations = ['normal'];
			clicked = true;
		};

		this.button = new FlxUIButton(0, 0, initialString, onClick);
		var upSprite = AssetPaths.rewardItemButton__png;
		//	var hoverSprite = AssetPaths.rewardItemButton_hover__png;
		var hoverSprite = AssetPaths.rewardItemButton__png;
		var downSprite = AssetPaths.rewardItemButton_pressed__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		button.loadGraphicSlice9(graphicArray, width, height, slice9Array);

		button.setLabelFormat(Fonts.STANDARD_FONT, 18, FlxColor.BLACK);
		button.autoCenterLabel();
		button.centerSprite();
		add(button);

		add(subscreen);
		subscreen.setPosition(FlxG.width / 2, FlxG.height / 2);
		subscreen.kill();
	}
}

/** a subscreen showing 3 skills. The user clicks one to claim it. It's centered. **/
class SkillRewardsSubScreen extends FlxSpriteGroup
{
	public function new(onClaim:Void->Void)
	{
		super();

		// create a grey see-through background to dim the outside
		var screen = new FlxSprite(0, 0);
		screen.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 128));
		screen.centerSprite();
		add(screen);

		var rewards = RewardHelper.getSkillRewards();
		for (i in 0...rewards.length)
		{
			var skillCard = new SkillCard(rewards[i], true);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, rewards.length, skillCard.width, 16);
			skillCard.setPosition(xPos, 0);
			add(skillCard);

			FlxMouseEventManager.add(skillCard);
			var onClick = (_) ->
			{
				Player.gainSkill(skillCard.skill);
				onClaim();
				this.kill(); // possible memory leak?
			};
			FlxMouseEventManager.setMouseClickCallback(skillCard, onClick);
		}
	}
}
