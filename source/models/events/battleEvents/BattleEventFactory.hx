package models.events.battleEvents;

import flixel.math.FlxRandom;
import models.player.CharacterInfo;
import models.player.Deck;
import models.skills.SkillFactory as SF;

class BattleEventFactory
{
	/** This is a queue of battle events that will be popped from every time the player encounters a battle.
	 * It will be shuffled at the start of a run.
	**/
	static var battleQueueEnd = [dogs, ghosts, firewood, golem, dandelions];

	static var battleQueueStart = [slime, dog];

	public static var battleQueue:Array<Void->BattleEvent> = [];

	public static function getNextBattleEvent():BattleEvent
	{
		return battleQueue.shift()();
	}

	/** init the factory's battle queue, so it can start serving the battle events. **/
	public static function init()
	{
		var random = new FlxRandom();
		random.shuffle(battleQueueStart);
		random.shuffle(battleQueueEnd);
		battleQueue = battleQueueStart.concat(battleQueueEnd);
	}

	public static function trainingDummy()
	{
		var createDummy = () ->
		{
			var skills = [SF.enemySkills.get(dummy)()];
			var dummyChar = CharacterInfo.createEnemy('Dummy', AssetPaths.trainingDummy__png, 15, skills);
			return dummyChar;
		};

		var name = 'Training Dummy';
		var desc = 'You decide to spar with the training dummy before heading out.';
		var enemies = [createDummy()];
		var deck = Deck.fromMap([CON => 10]);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function slime()
	{
		var createSlime = () ->
		{
			var skills = [SF.enemySkills.get(tackle)(1)];
			var slime = CharacterInfo.createEnemy('Slime', AssetPaths.giantSlime__png, 15, skills);
			slime.avatarPath = AssetPaths.SlimeAvatar__png;
			return slime;
		};

		var name = 'Slime';
		var desc = 'There\'s a giant slime in your path. It\'s cute. It attacks.';
		var enemies = [createSlime()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([POW => 5], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createDog = () ->
	{
		var skills = [SF.enemySkills.get(houndBite)(), SF.enemySkills.get(houndRam)()];
		var dog = CharacterInfo.createEnemy('Dog', AssetPaths.poochyena__png, 15, skills);
		return dog;
	};

	public static function dog()
	{
		var name = 'A Robotic Dog';
		var desc = 'You stumble upon a lone mechanical dog. It\'s hostile. Who made this thing?';
		var enemies = [createDog()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([AGI => 5], hiddenCards);

		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function dogs()
	{
		var name = 'Pack of Robtic Dogs';
		var desc = 'You stumble upon a group of those robotic attack dogs. Someone must have manufactured a bunch of them.';
		var enemies = [createDog(), createDog()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([AGI => 10], hiddenCards);
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

	static var createGhostF = () ->
	{
		var skills = [SF.enemySkills.get(spook)(), SF.enemySkills.get(giveLife)(1)];
		var ghost = CharacterInfo.createEnemy('Ghost Type F', AssetPaths.ghost2__png, 15, skills);
		ghost.avatarPath = AssetPaths.ghost2Avatar__png;
		ghost.initialStatuses = [LASTBREATH];
		return ghost;
	}

	static var createGhostC = () ->
	{
		var skills = [SF.enemySkills.get(spook)()];
		var ghost = CharacterInfo.createEnemy('Ghost Type C', AssetPaths.ghost3__png, 15, skills);
		ghost.avatarPath = AssetPaths.ghost3Avatar__png;
		ghost.initialStatuses = [DYINGWISH];
		return ghost;
	}

	public static function ghosts()
	{
		var name = 'Spooky Ghosts';
		var desc = 'Some woodland ghosts float towards you.';
		var enemies = [createGhostF(), createGhostF(), createGhostF()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([KNO => 14, POW => 6], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function ghosts2()
	{
		var name = 'Spooky Ghosts Round 2';
		var desc = 'Some more woodland ghosts float towards you. Some of them look much stronger than usual ghosts.';
		var enemies = [createGhostF(), createGhostF(), createGhostC(), createGhostC()];
		var hiddenCards = 1;
		var deck = Deck.fromMap([KNO => 12, POW => 8], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function firewood()
	{
		var createFireWood = () ->
		{
			var skills = [SF.enemySkills.get(hotHands)(), SF.enemySkills.get(flameShield)()];
			var draw = 2;
			var firewood = CharacterInfo.createEnemy('Firewood', AssetPaths.firewood__png, 30, skills, draw);
			firewood.avatarPath = AssetPaths.firewoodAvatar__png;
			return firewood;
		};

		var name = 'Flaming Wood Sprite';
		var desc = 'Something ghastly is burning over there.';
		var enemies = [createFireWood()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([POW => 10, CON => 10], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function golem()
	{
		var createGolem = () ->
		{
			var skills = [SF.enemySkills.get(golemSmash)()];
			var draw = 4;
			var golem = CharacterInfo.createEnemy('Golem', AssetPaths.golem__png, 40, skills, draw);
			golem.avatarPath = AssetPaths.golemAvatar__png;
			return golem;
		};

		var name = 'Golem';
		var desc = 'A hulking creature made of soil and stone towers over you.';
		var enemies = [createGolem()];
		var hiddenCards = 1;
		var deck = Deck.fromMap([POW => 10, CON => 10], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function dandelions()
	{
		var createGreenDanelion = () ->
		{
			var skills = [SF.enemySkills.get(petalShield)()];
			var draw = 1;
			var gd = CharacterInfo.createEnemy('Green Dandelion', AssetPaths.dandelionGreen__png, 20, skills, draw);
			gd.avatarPath = AssetPaths.golemAvatar__png;
			gd.initialStatuses = [PETALARMOR];
			return gd;
		};

		var createRedDanelion = () ->
		{
			var skills = [SF.enemySkills.get(petalBlade)()];
			var draw = 1;
			var rd = CharacterInfo.createEnemy('Red Dandelion', AssetPaths.dandelionRed__png, 20, skills, draw);
			rd.avatarPath = AssetPaths.golemAvatar__png;
			rd.initialStatuses = [PETALSPIKES];
			return rd;
		};

		var name = 'Dandelions';
		var desc = 'A couple of flowers seemingly spring to life!';
		var enemies = [createGreenDanelion(), createRedDanelion()];
		var hiddenCards = 0;
		var deck = Deck.fromMap([POW => 8, CON => 8], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function bat()
	{
		// uses "blind fire", fires many shots randomly
	}
}
