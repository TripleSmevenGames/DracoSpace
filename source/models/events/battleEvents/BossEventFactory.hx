package models.events.battleEvents;

import models.player.CharacterInfo;
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
		var numDraw = 3;
		var hp = 150;
		var rattle = CharacterInfo.createEnemy('Rattle', AssetPaths.poochyena__png, hp, skills, numDraw);
		rattle.initialStatuses = [CUNNING];

		var name = 'Rattle, The Twin Fangs';
		var desc = 'A snake lady blocks your path.';
		var enemies = [rattle];
		var hiddenCards = 1;
		var deck = Deck.fromMap([POW => 10, AGI => 10, WIS => 3], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BOSS);
	}

	public static function pin()
	{
		var SF = models.skills.SkillFactoryPin;

		// his dogs' skills will have priority: 0
		var skills = [SF.pinSkills.get(summonK9)(2), SF.pinSkills.get(commandGuard)(1),];
		var numDraw = 4;
		var hp = 100;
		var pin = CharacterInfo.createEnemy('Pin', AssetPaths.poochyena__png, hp, skills, numDraw);
		pin.initialStatuses = [OBSERVATION];

		var name = 'Pin, The Machinist';
		var desc = 'A group of robot dogs emerge, along with what looks like their leader.';
		var enemies = [pin];
		var hiddenCards = 1;
		var deck = Deck.fromMap([POW => 10, CON => 8, KNO => 5], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BOSS);
	}
}
