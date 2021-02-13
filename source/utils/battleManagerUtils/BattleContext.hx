package utils.battleManagerUtils;

import flixel.math.FlxRandom;
import haxe.Exception;
import models.player.CharacterInfo.CharacterType;
import ui.battle.DeckSprite;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusType;

/** Hopefully encapsulates everything you would need to know about the current state of battle.**/
class BattleContext
{
	public var pDeck:DeckSprite;
	public var eDeck:DeckSprite;
	public var pChars:Array<CharacterSprite>;
	public var eChars:Array<CharacterSprite>;

	public function getChars(type:CharacterType)
	{
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
			if (char.hasStatus(status) > 0)
				charsWithStatus.push(char);
		}
		return charsWithStatus;
	}

	public function getAlive(type:CharacterType)
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

	public function getRandomTarget(type:CharacterType)
	{
		var chars = getAlive(type);
		if (chars.length == 0)
		{
			throw new Exception('tried to get random target, but chars.length was 0');
		}
		return chars[new FlxRandom().int(0, chars.length - 1)];
	}

	/** Remove all Static from all characters and return the total amount expended. **/
	public function expendStatic():Int
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
	}
}
