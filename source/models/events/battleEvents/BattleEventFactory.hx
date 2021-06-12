package models.events.battleEvents;

import flixel.math.FlxRandom;
import models.CharacterInfo;
import models.player.Deck;
import models.player.Player;
import models.skills.Skill;
import models.skills.SkillFactory as SF;

using utils.GameUtils;

class BattleEventFactory
{
	/** This is a queue of battle events that will be used from every time the player encounters a battle.
	 * It will be shuffled at the start of a run.
	**/
	static var battleQueueMed = [
		twoSlimes,
		ghostsC,
		ghostsF,
		firewood,
		bush,
		dandelions,
		ghostAndDandelion,
		mushroom,
	];

	static var battleQueueMedCounter = 0;

	static var battleQueueEasy = [greenSlime, dandelion, ghosts];
	static var battleQueueEasyCounter = 0;

	static var battleQueueElite = [ghostsElite, darkFirewood];
	static var battleQueueEliteCounter = 0;

	static function getBattleFromQueue(queue:Array<Void->BattleEvent>, counter:Int)
	{
		if (counter < queue.length)
		{
			return queue[counter]();
		}
		else
		{
			// somehow the counter grew past the queue's length. Shouldn't happen, but if it does,
			// just return something random as a fallback.
			return queue.getRandomChoice()();
		}
	}

	public static function getNextBattleEvent():BattleEvent
	{
		var retVal:BattleEvent;
		if (Player.battlesFought < 4 || Player.getColumn() < 4)
		{
			retVal = getBattleFromQueue(battleQueueEasy, battleQueueEasyCounter);
			battleQueueEasyCounter += 1;
		}
		else
		{
			retVal = getBattleFromQueue(battleQueueMed, battleQueueMedCounter);
			battleQueueMedCounter += 1;
		}
		return retVal;
	}

	public static function getNextEliteEvent():BattleEvent
	{
		var retVal = getBattleFromQueue(battleQueueElite, battleQueueEliteCounter);
		battleQueueEliteCounter += 1;

		return retVal;
	}

	/** randomize the factory's battle queues, so every playthrough is different. **/
	public static function init()
	{
		var random = new FlxRandom();
		random.shuffle(battleQueueEasy);
		random.shuffle(battleQueueMed);
		random.shuffle(battleQueueElite);
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
		var slime = CharacterInfo.createEnemy('Green Slime', spriteSheetInfo, 12, skills);
		slime.avatarPath = AssetPaths.SlimeAvatar__png;
		slime.soundType = SLIME;
		return slime;
	};

	static var createBlueSlime = () ->
	{
		var skills = [SF.enemySkills.get(waterBlast)(), SF.enemySkills.get(springWater)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.blueSlime60x60x12__png, 60, 60, 12);
		var slime = CharacterInfo.createEnemy('Blue Slime', spriteSheetInfo, 14, skills);
		slime.avatarPath = AssetPaths.SlimeAvatar__png;
		slime.soundType = SLIME;
		return slime;
	};

	static function greenSlime()
	{
		var name = 'Green Slime';
		var desc = 'There\'s a giant slime in your path. It\'s cute. It attacks.';
		var enemies = [createGreenSlime()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 3, CON => 3], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function twoSlimes()
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

	static function dog()
	{
		var name = 'A Robotic Dog';
		var desc = 'You stumble upon a hostile mechanical dog. It clearly doesn\'t belong in the forest. Who made this?';
		var enemies = [createDog()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([AGI => 5], hiddenCards, draw);

		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function dogs()
	{
		var name = 'Pack of Robtic Dogs';
		var desc = 'You stumble upon a group of those robotic attack dogs. Someone must be manufacturing them.';
		var enemies = [createDog(), createDog()];
		var hiddenCards = 0;
		var deck = new Deck([AGI => 10], hiddenCards);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createGhostF = (level = 0) ->
	{
		var skills = new Array<Skill>();
		if (level == 0)
			skills.push(SF.enemySkills.get(spook)());
		else
			skills.push(SF.enemySkills.get(spook2)());
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.GhostF32x40x16__png, 32, 40, 16);
		var hp = 8 + (level * 4);
		var ghost = CharacterInfo.createEnemy('Ghost Type F', spriteSheetInfo, hp, skills);
		ghost.avatarPath = AssetPaths.ghost2Avatar__png;
		ghost.initialStatuses = level == 0 ? [] : [HAUNT];
		ghost.soundType = GHOST;
		return ghost;
	}

	static var createGhostC = (level = 0) ->
	{
		var skills = new Array<Skill>();
		if (level == 0)
			skills.push(SF.enemySkills.get(spook)());
		else
			skills.push(SF.enemySkills.get(spook2)());
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.GhostC32x40x16__png, 32, 40, 16);
		var hp = 8 + (level * 4);
		var ghost = CharacterInfo.createEnemy('Ghost Type C', spriteSheetInfo, hp, skills);
		ghost.avatarPath = AssetPaths.ghost3Avatar__png;
		ghost.initialStatuses = level == 0 ? [] : [ATTACK, DYINGWISH];
		ghost.soundType = GHOST;
		return ghost;
	}

	static function ghosts()
	{
		var name = 'Spooky Ghosts';
		var desc = 'Whatever\'s been going on in the forest has awakened the local spirits. These aren\'t the friendly kind. ';
		var enemies = [createGhostF(0), createGhostC(0)];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([KNO => 4, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function ghostsC()
	{
		var name = 'Spooky Ghosts';
		var desc = 'Some more woodland ghosts float towards you. They look a bit stronger than usual ghosts.';
		var enemies = [createGhostC(1), createGhostC(1)];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([KNO => 8, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function ghostsF()
	{
		var name = 'Spooky Ghosts';
		var desc = 'Some more woodland ghosts float towards you. They look a bit stronger than usual ghosts.';
		var enemies = [createGhostC(1), createGhostC(1)];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([KNO => 8, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function ghostsElite()
	{
		var name = 'Spooky Ghosts Elite';
		var desc = 'Some more woodland ghosts float towards you. They look much stronger than usual ghosts.';
		var enemies = [createGhostF(2), createGhostF(2), createGhostC(2), createGhostC(2)];
		var hiddenCards = 0;
		var draw = 4;
		var deck = new Deck([KNO => 10, CON => 5], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function firewood()
	{
		var createFirewood = () ->
		{
			var skills = [SF.enemySkills.get(hotHands)(), SF.enemySkills.get(flameShield)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.firewood80x60x12__png, 80, 60, 12);
			var firewood = CharacterInfo.createEnemy('Firewood', spriteSheetInfo, 25, skills);
			firewood.avatarPath = AssetPaths.firewoodAvatar__png;
			return firewood;
		};

		var name = 'Flaming Wood Sprite';
		var desc = 'Something ghastly is burning over there.';
		var enemies = [createFirewood()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 6, CON => 6, AGI => 6], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function darkFirewood()
	{
		var createDarkFirewood = () ->
		{
			var skills = [SF.enemySkills.get(cursedHands)(), SF.enemySkills.get(cursedFlame)()];
			var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.darkFirewood80x60x12__png, 80, 60, 12);
			var darkFirewood = CharacterInfo.createEnemy('Cursed Firewood', spriteSheetInfo, 35, skills);
			darkFirewood.avatarPath = AssetPaths.darkFirewoodAvatar__png;
			return darkFirewood;
		};

		var name = 'Dark Flaming Wood Sprite';
		var desc = 'Something ghastly is burning over there.';
		var enemies = [createDarkFirewood()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 8, CON => 8, AGI => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function golem()
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
		var desc = 'Something awakened this ancient weapon of war from the nearby ruins.';
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
		var gd = CharacterInfo.createEnemy('Green Dandelion', spriteSheetInfo, 14, skills);
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
		var hp = weak ? 10 : 14;
		var rd = CharacterInfo.createEnemy('Red Dandelion', spriteSheetInfo, hp, skills);
		rd.avatarPath = AssetPaths.dandelionRedAvatar__png;
		if (!weak)
			rd.initialStatuses = [PETALSPIKES];
		rd.soundType = PLANT;
		return rd;
	};

	static function dandelion()
	{
		var name = 'Dandelion';
		var desc = 'Dandelions normally aren\'t hostile. But the disturbance in the forest must be agitating them. One of them attacks you!';
		var enemies = [createRedDanelion(true)];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 4, CON => 2], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function dandelions()
	{
		var name = 'Dandelions';
		var desc = 'Dandelions normally aren\'t hostile. But the disturbance in the forest must be agitating them. ' + 'A group of them attack you!';
		var enemies = [createGreenDanelion(), createRedDanelion()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 8, CON => 8], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function ghostAndDandelion()
	{
		var name = 'Ghosts and Dandelions';
		var desc = 'A dandelion has teamed up with some ghosts to oppose you.';
		var enemies = [createGreenDanelion(), createGhostF(), createGhostF()];
		var hiddenCards = 0;
		var draw = 3;
		var deck = new Deck([KNO => 8, CON => 4], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createMushroom = () ->
	{
		var skills = [SF.enemySkills.get(shroomSpines)(), SF.enemySkills.get(grow)(1)];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.Moonshroom50x72x14__png, 50, 72, 14);
		var mushroom = CharacterInfo.createEnemy('Moonshroom', spriteSheetInfo, 20, skills);
		mushroom.avatarPath = AssetPaths.SlimeAvatar__png;
		mushroom.soundType = PLANT;
		return mushroom;
	}

	static function mushroom()
	{
		var name = 'Mushroom';
		var desc = 'A mushroom pops out of the ground and glares at ${Player.chars[0].name}. It\'s probably not edible. ';
		var enemies = [createMushroom()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 6, CON => 4], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createBush = () ->
	{
		var skills = [SF.enemySkills.get(acornShot)()];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.lionBush64x64x18__png, 64, 64, 18);
		var bush = CharacterInfo.createEnemy('Bush Lion', spriteSheetInfo, 20, skills);
		bush.avatarPath = AssetPaths.SlimeAvatar__png;
		bush.soundType = PLANT;
		return bush;
	}

	static function bush()
	{
		var name = 'Bush';
		var desc = '${Player.chars[1].name} notices a strange bush. Except, it\'s not a bush.';
		var enemies = [createBush()];
		var hiddenCards = 0;
		var draw = 1;
		var deck = new Deck([POW => 6, CON => 4], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static function mushroomBush()
	{
		var name = 'Mushroom and Bush';
		var desc = 'The forest is really trying to stop you. A moonshroom and lion bush both appear!';
		var enemies = [createBush(), createMushroom()];
		var hiddenCards = 0;
		var draw = 2;
		var deck = new Deck([POW => 10, CON => 4], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	static var createStoneHexapod = () ->
	{
		var skills = [SF.enemySkills.get(laserBolt)(), SF.enemySkills.get(laserBlast)(1)];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.rockAnt__png, 80, 50, 1);
		var rockAnt = CharacterInfo.createEnemy('Stone Hexapod', spriteSheetInfo, 25, skills);
		rockAnt.avatarPath = AssetPaths.rockAntAvatar__png;
		rockAnt.initialStatuses = [STURDY];
		rockAnt.soundType = ROCK;
		return rockAnt;
	}

	static var createStoneSentry = (type:Int = 0) ->
	{
		var skills = [SF.enemySkills.get(energize)(1)];
		var spriteSheetInfo = CharacterInfo.newSpriteSheetInfo(AssetPaths.stoneSentry50x50x2__png, 50, 50, 2);
		var stoneSentry = CharacterInfo.createEnemy('Stone Sentry', spriteSheetInfo, 10, skills);
		stoneSentry.avatarPath = AssetPaths.stoneSentryAvatar__png;
		stoneSentry.initialStatuses = [STURDY];
		stoneSentry.soundType = ROCK;
		return stoneSentry;
	}

	static function stoneHexapod()
	{
		var name = 'Stone Hexapod';
		var desc = 'Something awoke these ancient machines from the nearby ruins.';
		var enemies = [createStoneHexapod(), createStoneSentry()];
		var hiddenCards = 0;
		var draw = 3;
		var deck = new Deck([KNO => 10, WIS => 3], hiddenCards, draw);
		return new BattleEvent(name, desc, enemies, deck, BATTLE);
	}

	public static function bat()
	{
		// uses "blind fire", fires many shots randomly
	}
}
