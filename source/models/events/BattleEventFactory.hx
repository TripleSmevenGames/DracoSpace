package models.events;

import models.player.CharacterInfo;
import models.player.Deck;
import models.skills.SkillFactory as SF;

class BattleEventFactory
{
	public static function trainingDummy()
	{
		var createDummy = () ->
		{
			var skills = [SF.enemySkills.get(dummy)()];
			var dummyChar = CharacterInfo.createEnemy('Dummy', AssetPaths.trainingDummy__png, 15, skills);
			return dummyChar;
		};

		var name = 'Training Dummy';
		var desc = 'Tutorial: Combat. Skip this if you\'re already familiar with combat';
		var enemies = [createDummy()];
		var deck = Deck.fromMap([CON => 10]);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function slime()
	{
		var createSlime = () ->
		{
			var skills = [SF.enemySkills.get(tackle)(1)];
			var slime = CharacterInfo.createEnemy('Dog', AssetPaths.gulpin__png, 15, skills);
			return slime;
		};

		var name = 'Pack of Animals';
		var desc = 'There\'s a green blob of...something in the way. It attacks.';
		var enemies = [createSlime()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([POW => 5, AGI => 5], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function dogs()
	{
		var createDog = () ->
		{
			var skills = [SF.enemySkills.get(howl)(1), SF.enemySkills.get(bite)()];
			var dog = CharacterInfo.createEnemy('Dog', AssetPaths.poochyena__png, 15, skills);
			return dog;
		};

		var name = 'Pack of Animals';
		var desc = 'Your party stumbles upon a group of some sort of Dogs. They don\'t look friendly...';
		var enemies = [createDog(), createDog()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([POW => 5, AGI => 5], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
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

	public static function ghosts()
	{
		var createGhost = () ->
		{
			var skills = [SF.enemySkills.get(spook)(), SF.enemySkills.get(giveLife)(1)];
			var ghost = CharacterInfo.createEnemy('Ghost', AssetPaths.ghost2__png, 15, skills);
			ghost.initialStatuses = [LASTBREATH];
			return ghost;
		}

		var name = 'Spooky Ghosts';
		var desc = 'Some woodland ghosts float towards you.';
		var enemies = [createGhost(), createGhost(), createGhost(), createGhost()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([KNO => 12, POW => 8], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function bat()
	{
		// uses "blind fire", fires many shots randomly
	}
}
