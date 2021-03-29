package models.events;

import models.player.CharacterInfo;
import models.player.Deck;
import models.skills.SkillFactory as SF;

class BattleEventFactory
{
	static function createDog()
	{
		var skills = [SF.enemySkills.get(howl)(1), SF.enemySkills.get(bite)()];
		var dog = CharacterInfo.createEnemy('Dog', AssetPaths.poochyena__png, 15, skills);
		return dog;
	}

	public static function dogs()
	{
		var name = 'Pack of Animals';
		var desc = 'Your party stumbles upon a group of some sort of Dogs. They don\'t look friendly...';
		var enemies = [createDog(), createDog()];
		var hiddenCards = 1;
		var deck = Deck.fromMap([POW => 5, AGI => 5], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function createDrone()
	{
		var skills = [SF.enemySkills.get(laserBolt)(1), SF.enemySkills.get(selfDestruct)()];
		var drone = CharacterInfo.createEnemy('Drone', AssetPaths.magnemite__png, 12, skills);
		return drone;
	}

	public static function drones()
	{
		var createDrone = () ->
		{
			var skills = [SF.enemySkills.get(laserBolt)(1), SF.enemySkills.get(selfDestruct)()];
			var drone = CharacterInfo.createEnemy('Drone', AssetPaths.magnemite__png, 12, skills);
			return drone;
		}

		var name = 'Drone Swarm';
		var desc = 'There\'s a swarm of drones up ahead. A few of them break off and attack your party.';
		var enemies = [createDrone(), createDrone(), createDrone()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([KNO => 14, WIS => 1], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function bat()
	{
		// uses "blind fire", fires many shots randomly
	}
}
