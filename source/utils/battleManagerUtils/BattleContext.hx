package utils.battleManagerUtils;

import flixel.math.FlxRandom;
import haxe.Exception;
import models.CharacterInfo.CharacterType;
import ui.battle.ITurnTriggerable;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import ui.battle.status.Status.StatusType;

using utils.GameUtils;

/** Hopefully encapsulates everything you would need to know about the current state of battle.**/
class BattleContext
{
	public var pDeck:DeckSprite;
	public var eDeck:DeckSprite;
	public var pChars:Array<CharacterSprite>;
	public var eChars:Array<CharacterSprite>;
	public var turnTriggerables:Array<ITurnTriggerable>;
	public var turnCounter:Int = 0;

	public function getChars(?type:CharacterType)
	{
		if (type == null)
			return eChars.concat(pChars);
		if (type == ENEMY)
			return eChars;
		if (type == PLAYER)
			return pChars;

		return null;
	}

	public function areCharacterHurtAnimationsPlaying()
	{
		for (char in pChars)
			if (char.isPlayingHurtAnimation())
				return true;

		for (char in eChars)
			if (char.isPlayingHurtAnimation())
				return true;

		return false;
	}

	public function areAllCharsDead(type:CharacterType)
	{
		var chars = getChars(type);

		for (char in chars)
		{
			if (!char.dead)
				return false;
		}
		return true;
	}

	public function getCharsWithStatus(status:StatusType, type:CharacterType)
	{
		var chars = getChars(type);

		var charsWithStatus:Array<CharacterSprite> = [];
		for (char in chars)
		{
			if (char.getStatus(status) > 0 && !char.dead)
				charsWithStatus.push(char);
		}
		return charsWithStatus;
	}

	public function getAlive(?type:CharacterType)
	{
		var alive:Array<CharacterSprite> = [];
		var chars = getChars(type);
		for (char in chars)
		{
			if (!char.dead)
				alive.push(char);
		}
		return alive;
	}

	public function getAliveEnemies()
	{
		return getAlive(ENEMY);
	}

	public function getAlivePlayers()
	{
		return getAlive(PLAYER);
	}

	/** Enter null as the CharacterType to choose among all characters (player and enemy). **/
	public function getRandomTarget(?type:CharacterType)
	{
		var chars = getAlive(type);
		if (chars.length == 0)
		{
			throw new Exception('tried to get random target, but chars.length was 0');
		}
		return chars.getRandomChoice();
	}

	/** Get a living enemy with the lowest hp. Returns null if there are no more enemies. **/
	public function getLowestHealthEnemy():Null<CharacterSprite>
	{
		var aliveEnemies = getAliveEnemies();
		var lowestEnemy = null;
		var lowestHp = 99999;
		for (enemy in aliveEnemies)
		{
			if (enemy.currHp < lowestHp)
			{
				lowestEnemy = enemy;
				lowestHp = enemy.currHp;
			}
		}
		return lowestEnemy;
	}

	public function getHighestHealthPlayer():Null<CharacterSprite>
	{
		var alivePlayers = getAlivePlayers();
		var highestPlayer = null;
		var highestHp = 0;
		for (player in alivePlayers)
		{
			if (player.currHp > highestHp)
			{
				highestPlayer = player;
				highestHp = player.currHp;
			}
		}
		return highestPlayer;
	}

	/** Remove all Static from all characters and return the total amount expended. **/
	public function expendAllStatic():Int
	{
		var total = 0;
		for (char in pChars)
		{
			total = char.removeStatus(STATIC);
		}
		return total;
	}

	public function new(pDeck:DeckSprite, eDeck:DeckSprite, pChars:Array<CharacterSprite>, eChars:Array<CharacterSprite>)
	{
		this.pDeck = pDeck;
		this.eDeck = eDeck;
		this.pChars = pChars;
		this.eChars = eChars;

		// add the players first then the decks after.
		// I dont remember why but I think something breaks if you do it in the wrong order.
		this.turnTriggerables = [];
		for (char in pChars.concat(eChars))
			turnTriggerables.push(char);
		turnTriggerables.push(pDeck);
		turnTriggerables.push(eDeck);
	}
}
