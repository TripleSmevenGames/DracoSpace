package models.events.battleEvents;

import models.CharacterInfo;
import models.player.Deck;

class BossEventFactory
{
	public static function rattle()
	{
		var SF = models.skills.SkillFactoryRattle;

		var skills = [
			SF.rattleSkills.get(rattlesGaze)(2),
			SF.rattleSkills.get(snakeFangs)(),
			SF.rattleSkills.get(crossCutter)(1)
		];
		var hp = 60;
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.rattleIdle72x61x16__png, 72, 61, 16);
		var rattle = CharacterInfo.createEnemy('Rattle', spriteSheetInfo, hp, skills);
		rattle.avatarPath = AssetPaths.RattleAvatar__png;
		rattle.initialStatuses = [CUNNING];

		var name = 'Rattle, The Twin Fangs';
		var desc = 'A snake lady blocks your path.';
		var enemies = [rattle];
		var hiddenCards = 1;
		var numDraw = 3;
		var deck = new Deck([POW => 10, AGI => 10, WIS => 3], hiddenCards, numDraw);
		return new BattleEvent(name, desc, enemies, deck, BOSS);
	}

	public static function pin()
	{
		var SF = models.skills.SkillFactoryPin;

		// his dogs' skills will have priority: 0
		var skills = [SF.pinSkills.get(summonK9)(2), SF.pinSkills.get(commandGuard)(1),];
		var hp = 100;
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.YellowSword__png, 45, 42, 1);
		var pin = CharacterInfo.createEnemy('Pin', spriteSheetInfo, hp, skills);

		var name = 'Dr. Pin, The Machinist';
		var desc = 'A group of robot dogs emerge, along with what looks like their leader.';
		var enemies = [pin];
		var hiddenCards = 1;
		var numDraw = 4;
		var deck = new Deck([AGI => 10, CON => 8, KNO => 5], hiddenCards, numDraw);
		return new BattleEvent(name, desc, enemies, deck, BOSS);
	}
}
