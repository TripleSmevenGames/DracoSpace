package ui.battle.character;

import flixel.FlxSprite;
import managers.GameController;
import ui.TooltipLayer.Tooltip;
import ui.battle.IndicatorIcon.TooltipPlace;

using utils.ViewUtils;

/** Shows this character's avatar. After adding this, call setupHover() to get the hover effect. Not centered.**/
class CharacterAvatar extends FlxSprite
{
	public var char:CharacterSprite;

	var place:TooltipPlace;

	static final PLACE_HOLDER_AVATAR = AssetPaths.trainingDummyAvatar__png;

	/**add the tooltip showing the character's name on hover. Call this after add()'ing this to the parent. **/
	public function setupHover()
	{
		this.addScaledToMouseManager();
		var tooltip = Tooltip.genericTooltip(char.info.name, null, {width: 0});
		if (place == null || place == BATTLE)
			GameController.battleTooltipLayer.registerTooltip(tooltip, this);
		else if (place == INV)
			GameController.invTooltipLayer.registerTooltip(tooltip, this);
	}

	public function new(char:CharacterSprite, ?hover:Bool = true, ?place:TooltipPlace)
	{
		this.char = char;
		this.place = place;
		var avatarPath = char.info.avatarPath != null ? char.info.avatarPath : PLACE_HOLDER_AVATAR;
		super(0, 0, avatarPath);
		this.scale3x();
	}
}
