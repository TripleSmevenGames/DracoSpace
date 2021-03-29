package models.events;

import models.player.CharacterInfo;
import models.player.Deck;
import models.skills.SkillFactory as SF;

class BossEventFactory
{
	public static function rattle()
	{
		var skills = [
			SF.rattleSkills.get(piercingGaze)(1),
			SF.rattleSkills.get(snakeBite)(),
			SF.rattleSkills.get(snakeWhip)()
		];
		var rattle = CharacterInfo.createEnemy('Rattle', AssetPaths.poochyena__png, 100, skills, 3);
		var name = 'Rattle';

		var desc = 'A snake lady blocks your path.';
		var enemies = [rattle];
		var hiddenCards = 1;
		var deck = Deck.fromMap([POW => 10, AGI => 10, WIS => 3], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}
}
