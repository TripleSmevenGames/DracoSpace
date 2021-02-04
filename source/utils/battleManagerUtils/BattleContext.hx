package utils.battleManagerUtils;

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

	public function getAliveEnemies()
	{
		var aliveEnemies:Array<CharacterSprite> = [];
		for (char in eChars)
		{
			if (!char.dead)
				aliveEnemies.push(char);
		}
		return aliveEnemies;
	}

	public function new(pDeck:DeckSprite, eDeck:DeckSprite, pChars:Array<CharacterSprite>, eChars:Array<CharacterSprite>)
	{
		this.pDeck = pDeck;
		this.eDeck = eDeck;
		this.pChars = pChars;
		this.eChars = eChars;
	}
}
