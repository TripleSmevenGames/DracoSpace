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
	static var battleQueueEnd = [twoSlimes, dogs, ghosts2, firewood, golem, dandelions];

	static var battleQueueStart = [greenSlime, dandelion, ghosts];

	public static var battleQueue:Array<Void->BattleEvent> = [];

	public static function getNextBattleEvent():BattleEvent
	{
		if (battleQueue.length == 0)
			init();
		return battleQueue.shift()();
	}

	/** init the factory's battle queue, so it can start serving the battle events. **/
	public static function init()
	{
		var random = new FlxRandom();
		var start = battleQueueStart.copy();
		var end = battleQueueEnd.copy();
		random.shuffle(start);
		random.shuffle(end);
		battleQueue = start.concat(end);
	}

	public static function trainingDummy()
	{
		var createDummy = () ->
		{
			var skills = [SF.enemySkills.get(idle)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.trainingDummy__png, 48, 48, 1);
			var dummyChar = CharacterInfo.createEnemy('Dummy', spriteSheetInfo, 8, skills);
			dummyChar.avatarPath = AssetPaths.trainingDummyAvatar__png;
			dummyChar.soundType = PLANT;
			return dummyChar;
		};

		var name = 'Training Dummy';
		var desc = 'You decide to spar with the training dummy before heading out.';
		var enemies = [createDummy()];
		var deck = new Deck([CON => 10], 0, 1);
		return new BattleEvent(name, desc, enemies, deck, TUTORIAL);
	}

	static var createGreenSlime = () ->
	{
		var skills = [SF.enemySkills.get(tackle)(1)];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.greenSlime60x60x12__png, 60, 60, 12);
		var slime = CharacterInfo.createEnemy('Green Slime', spriteSheetInfo, 15, skills);
		slime.avatarPath = AssetPaths.SlimeAvatar__png;
		slime.soundType = SLIME;
		return slime;
	};

	static var createBlueSlime = () ->
	{
		var skills = [SF.enemySkills.get(waterBlast)(), SF.enemySkills.get(springWater)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.blueSlime60x60x12__png, 60, 60, 12);
		var slime = CharacterInfo.createEnemy('Blue Slime', spriteSheetInfo, 20, skills);
		slime.avatarPath = AssetPaths.SlimeAvatar__png;
		slime.soundType = SLIME;
		return slime;
	};

	public static function greenSlime()
	{
		var name = 'Green Slime';
		var desc = 'There\'s a giant slime in your path. It\'s cute. It attacks.';
		var enemies = [createGreenSlime()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 4, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function twoSlimes()
	{
		var name = 'Two Slimes';
		var desc = 'Now two slimes are in your way. This is getting out of control!';
		var enemies = [createGreenSlime(), createBlueSlime()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 5, CON => 3, KNO => 3], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createDog = () ->
	{
		var skills = [SF.enemySkills.get(houndBite)(), SF.enemySkills.get(houndRam)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.dogIdle48x52x1__png, 48, 52, 1);
		var dog = CharacterInfo.createEnemy('Dog', spriteSheetInfo, 12, skills);
		dog.avatarPath = AssetPaths.dogAvatar__png;
		return dog;
	};

	public static function dog()
	{
		var name = 'A Robotic Dog';
		var desc = 'You stumble upon a hostile mechanical dog. It clearly doesn\'t belong in the forest. Who made this?';
		var enemies = [createDog()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([AGI => 5], hiddenCards, draw);

		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function dogs()
	{
		var name = 'Pack of Robtic Dogs';
		var desc = 'You stumble upon a group of those robotic attack dogs. Someone must be manufacturing them.';
		var enemies = [createDog(), createDog()];
		var hiddenCards = 0;
		var deck = new Deck([AGI => 10], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	/**
		public static function drones()
			{
				var createDrone = () ->
				{
					var skills = [SF.enemySkills.get(laserBolt)(1), SF.enemySkills.get(selfDestruct)()];
					var spriteSheetInfo = {
						spritePath: AssetPaths.trainingDummy__png,
					};
					var drone = CharacterInfo.createEnemy('Drone', AssetPaths.magnemite__png, 12, skills);
					return drone;
				}
			
			var name = 'Drone Swarm';
			var desc = 'There\'s a swarm of drones up ahead. A few of them break off and attack your party.';
			var enemies = [createDrone(), createDrone(), createDrone()];
			var hiddenCards = 0;
			var deck = new Deck([KNO => 14, WIS => 1], hiddenCards);
			return new BattleEvent(name, desc, enemies, deck, BATTLE);
		}
	**/
	static var createGhostF = (weak:Bool = false) ->
	{
		var skills = [SF.enemySkills.get(spook)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.ghost2__png, 32, 40, 1);
		var hp = weak ? 8 : 10;
		var ghost = CharacterInfo.createEnemy('Ghost Type F', spriteSheetInfo, hp, skills);
		ghost.avatarPath = AssetPaths.ghost2Avatar__png;
		ghost.initialStatuses = weak ? [] : [LASTBREATH];
		ghost.soundType = GHOST;
		return ghost;
	}

	static var createGhostC = () ->
	{
		var skills = [SF.enemySkills.get(spook)(), SF.enemySkills.get(ghostlyStrength)(1)];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.ghost3__png, 32, 40, 1);
		var ghost = CharacterInfo.createEnemy('Ghost Type C', spriteSheetInfo, 15, skills);
		ghost.avatarPath = AssetPaths.ghost3Avatar__png;
		ghost.initialStatuses = [ATTACK, DYINGWISH];
		ghost.soundType = GHOST;
		return ghost;
	}

	public static function ghosts()
	{
		var name = 'Spooky Ghosts';
		var desc = 'Whatever\'s been going on in the forest has awakened the local spirits. These aren\'t the friendly kind. ';
		var enemies = [createGhostF(true), createGhostF(true)];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([KNO => 6, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function ghosts2()
	{
		var name = 'Spooky Ghosts Round 2';
		var desc = 'Some more woodland ghosts float towards you. They look much stronger than usual ghosts.';
		var enemies = [createGhostF(), createGhostF(), createGhostC(), createGhostC()];
		var hiddenCards = 0;
		var draw = 4;
		var deck = new Deck([KNO => 10, POW => 6, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function firewood()
	{
		var createFireWood = () ->
		{
			var skills = [SF.enemySkills.get(hotHands)(), SF.enemySkills.get(flameShield)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.firewood__png, 75, 55, 1);
			var firewood = CharacterInfo.createEnemy('Firewood', spriteSheetInfo, 30, skills);
			firewood.avatarPath = AssetPaths.firewoodAvatar__png;
			return firewood;
		};

		var name = 'Flaming Wood Sprite';
		var desc = 'Something ghastly is burning over there.';
		var enemies = [createFireWood()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 10, CON => 10], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function golem()
	{
		var createGolem = () ->
		{
			var skills = [SF.enemySkills.get(golemSmash)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.golem__png, 79, 96, 1);
			var golem = CharacterInfo.createEnemy('Golem', spriteSheetInfo, 40, skills);
			golem.avatarPath = AssetPaths.golemAvatar__png;
			golem.initialStatuses = [STURDY];
			golem.soundType = ROCK;
			return golem;
		};

		var name = 'Golem';
		var desc = 'A hulking creature made of soil and stone towers over you. Something awakened this ancient weapon of war.';
		var enemies = [createGolem()];
		var hiddenCards = 0;
		var draw = 4;
		var deck = new Deck([POW => 10, CON => 10], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createGreenDanelion = () ->
	{
		var skills = [SF.enemySkills.get(petalShield)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.dandelionGreenIdle32x32x10__png, 32, 32, 10);
		var gd = CharacterInfo.createEnemy('Green Dandelion', spriteSheetInfo, 18, skills);
		gd.avatarPath = AssetPaths.dandelionGreenAvatar__png;
		gd.initialStatuses = [PETALARMOR];
		gd.soundType = PLANT;
		return gd;
	};

	static var createRedDanelion = (weak:Bool = false) ->
	{
		var skills = [SF.enemySkills.get(petalBlade)()];
		var spriteSheet = weak ? AssetPaths.dandelionNoPetalIdle32x32x10__png : AssetPaths.dandelionRedIdle32x32x10__png;
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(spriteSheet, 32, 32, 10);
		var hp = weak ? 10 : 18;
		var rd = CharacterInfo.createEnemy('Red Dandelion', spriteSheetInfo, hp, skills);
		rd.avatarPath = AssetPaths.dandelionRedAvatar__png;
		if (!weak)
			rd.initialStatuses = [PETALSPIKES];
		rd.soundType = PLANT;
		return rd;
	};

	public static function dandelion()
	{
		var name = 'Dandelion';
		var desc = 'Dandelions normally aren\'t hostile. But the disturbance in the forest must be agitating them. One of them attacks you!';
		var enemies = [createRedDanelion(true)];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 4, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function dandelions()
	{
		var name = 'Dandelions';
		var desc = 'Dandelions normally aren\'t hostile. But the disturbance in the forest must be agitating them. ' + 'A group of them attack you!';
		var enemies = [createGreenDanelion(), createRedDanelion()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 8, CON => 8], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function rockAnt()
	{
		var createRockAnt = () ->
		{
			var skills = [SF.enemySkills.get(laserBolt)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.rockAnt__png, 80, 50, 1);

			var rockAnt = CharacterInfo.createEnemy('Stone Hexapod', spriteSheetInfo, 25, skills);
			rockAnt.avatarPath = AssetPaths.rockAntAvatar__png;
			rockAnt.initialStatuses = [STURDY];
			rockAnt.soundType = ROCK;
			return rockAnt;
		}

		var createStoneSentry = (type:Int = 0) ->
		{
			var skills = [];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.stoneSentry50x50x2__png, 50, 50, 2);
			var rockAnt = CharacterInfo.createEnemy('Stone Sentry', spriteSheetInfo, 10, skills);
			rockAnt.avatarPath = AssetPaths.rockAntAvatar__png;
			rockAnt.initialStatuses = [STURDY];
			rockAnt.soundType = ROCK;
			return rockAnt;
		}
	}

	public static function bat()
	{
		// uses "blind fire", fires many shots randomly
	}
}
