package ui.battle.combatUI;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using utils.ViewUtils;

/** This button appears when you are targeting a skill. Press it to cancel the targeting and refund spent cards.
 * The Battle Manager will set it's onclick.
 * Centered on the button sprite, and already added to mouse manager.
**/
class CancelSkillButton extends FlxSpriteGroup
{
	/** The actual clickable sprite. **/
	var button:FlxSprite;

	/** The text under the button saying "cancel". **/
	var subtitle:FlxText;

	public function setOnClick(onClick:Void->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(button, (_) -> onClick());
	}

	public function new()
	{
		super();

		this.button = new FlxSprite(0, 0, AssetPaths.cancelTargeting__png);
		button.scale3x();
		button.centerSprite();
		add(button);

		this.subtitle = new FlxText(0, 0, 0, 'Cancel Skill');
		subtitle.setFormat(Fonts.STANDARD_FONT, 24);
		subtitle.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		subtitle.centerSprite(0, button.height / 2 + subtitle.height / 2 + 4);
		add(subtitle);

		button.addScaledToMouseManager();
	}
}
