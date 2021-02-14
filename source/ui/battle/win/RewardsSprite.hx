package ui.battle.win;

import utils.ViewUtils;
import ui.battle.win.SkillRewardCard;
import ui.battle.win.SkillRewardCard;
import ui.battle.win.SkillRewardCard;
import utils.battleManagerUtils.RewardHelper;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUI9SliceSprite;
import flash.geom.Rectangle;

using utils.ViewUtils;

class RewardsSprite extends FlxSpriteGroup {
    public function new() {
        super();

		var body = new FlxUI9SliceSprite(0, 0, AssetPaths.space__png, new Rectangle(0, 0, 500, 600), [8, 8, 40, 40]);
        body.centerSprite();
        add(body);
        var rewards = RewardHelper.getSkillRewards();
        for (i in 0...rewards.length)
        {
            var skillCard = new SkillRewardCard(rewards[i]);
            var xPos = ViewUtils.getXCoordForCenteringLR(i, rewards.length, skillCard.width, 16);
            skillCard.setPosition(xPos, 0);
            add(skillCard);
        }


    }
}
