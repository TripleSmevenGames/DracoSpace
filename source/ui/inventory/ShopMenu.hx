package ui.inventory;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/** Really just a container for the SkillShop and UpgradeShop. NOT centered, place at 0, 0 **/
class ShopMenu extends FlxSpriteGroup
{
	var skillShop:SkillShop;
	var upgradeShop:UpgradeShop;

	public function refresh()
	{
		skillShop.refresh();
		upgradeShop.refresh();
	}

	public function new(headerHeight:Float)
	{
		super();

		skillShop = new SkillShop();
		skillShop.setPosition(FlxG.width / 2, headerHeight + 32);

		upgradeShop = new UpgradeShop();
		upgradeShop.setPosition(FlxG.width / 2, skillShop.y + skillShop.height + 64);

		add(skillShop);
		add(upgradeShop);
	}

	override public function revive()
	{
		// When we revive this, we don't actually want to revive _everything_, since some sprites need to be hidden.
		// calling refresh ensures the sprites that need to stay kill()'d are still kill()'d.
		super.revive();
		refresh();
	}
}
