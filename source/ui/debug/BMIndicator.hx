package ui.debug;

import flixel.text.FlxText;
import managers.BattleManager;

@:access(managers.BattleManager)
class BMIndicator extends FlxText
{
	var BM:BattleManager;

	public function new(BM:BattleManager)
	{
		super(0, 40, 0, 'BM:', 12);
		this.BM = BM;
		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float)
	{
		var state:String = '';
		var skill:String = '';

		state = BM.getState().getName();
		if (BM.activeSkillSprite != null)
			skill = BM.activeSkillSprite.skill.name;

		text = 'BM state: ${state}, active skill: ${skill}';
		super.update(elapsed / 2);
	}
}
