package ui.battle.combatUI;

import constants.Fonts;
import constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import utils.GameController;
import utils.GameUtils;
import utils.ViewUtils;

enum CardPileType
{
	DRAW;
	DISCARD;
	BUFFER;
}

/** represents either a drawpile or discard pile during battle. Or maybe another pile in the future (exiled cards?)
 * used with DeckSprite. Centered.
 */
class CardPile extends FlxSpriteGroup
{
	public var cards(null, null):Cards;
	public var hidden:Bool = false;

	var body:BattleIndicatorIcon;
	var desc:String;
	var type:CardPileType;
	var deck:Deck;

	public function updateStuff()
	{
		updateNum();
		updateTooltipDesc();
	}

	inline function updateTooltipDesc()
	{
		body.updateTooltipDesc(getDisplayString());
	}

	inline function updateNum()
	{
		body.updateDisplay(Std.string(cards.length));
	}

	public function getCards()
	{
		return cards.copy();
	}

	public function addCard(card:Card)
	{
		cards.push(card);
		updateStuff();
	}

	public function addCards(cards:Cards)
	{
		this.cards = this.cards.concat(cards);
		updateStuff();
	}

	public function drawCard()
	{
		var drawn = cards.pop();
		updateStuff();
		return drawn;
	}

	public function set(cards:Cards)
	{
		this.cards = cards;
		updateStuff();
	}

	public function clearPile()
	{
		cards = [];
		updateStuff();
	}

	public function shuffle()
	{
		GameController.rng.shuffle(cards);
	}

	// maybe slow because we're adding up a lot of maps
	function getCardMakeUp()
	{
		var makeUp = new Array<SkillPointCombination>();
		for (card in cards)
		{
			makeUp.push(card.skillPoints);
		}
		return SkillPointCombination.sum(makeUp);
	}

	function getDisplayString()
	{
		var makeUp = getCardMakeUp();
		var string = '';
		for (type in SkillPointCombination.ARRAY)
		{
			if (deck.cardMap.get(type) != 0)
			{
				var thisVal = '??';
				if (!hidden)
					thisVal = Std.string(makeUp.get(type));
				var totalVal = Std.string(deck.cardMap.get(type));
				string += '${type.getName()} : ${thisVal}/${totalVal} \n '; // spaces are so replacement text can find the \n
			}
		}
		return string;
	}

	public function new(type:CardPileType, deck:Deck, hidden:Bool = false)
	{
		super();
		cards = [];
		this.type = type;
		this.deck = deck;

		var spritePath = '';
		var name = 'nani';
		if (type == DRAW)
		{
			spritePath = AssetPaths.drawIcon__png;
			name = 'Draw';
		}
		else if (type == DISCARD)
		{
			spritePath = AssetPaths.discardIcon__png;
			name = 'Discard';
		}
		else
			trace('nani');

		var options:BattleIndicatorIconOptions = {
			color: FlxColor.WHITE,
			centered: true,
			centerTooltip: true,
			scale: 3,
			fontSize: 20,
			tooltipFontSize: 20,
			width: 100,
		};
		this.body = new BattleIndicatorIcon(spritePath, name, getDisplayString(), options);
		add(body);
	}
}
