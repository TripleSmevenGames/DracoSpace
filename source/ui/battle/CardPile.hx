package ui.battle;

import constants.Constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;
import utils.GameController;
import utils.GameUtils;
import utils.ViewUtils;

// represents either a drawpile or discard pile during battle. Or maybe another pile in the future (exiled cards?)
// used with DeckSprite.
class CardPile extends FlxSpriteGroup
{
	public var pileName:String;
	public var cards(null, null):Cards;

	var body:FlxSprite;
	var numCards:FlxText;
	var anchor:FlxSprite;

	inline function updateNum()
	{
		#if debug
		// trace('called updatedNum on ${pileName} with ${cards.length} cards');
		#end
		numCards.text = '${pileName}: ${cards.length}';
	}

	public function getCards()
	{
		return cards.copy();
	}

	public function addCard(card:Card)
	{
		cards.push(card);
		updateNum();
	}

	public function addCards(cards:Cards)
	{
		this.cards = this.cards.concat(cards);
		updateNum();
	}

	public function drawCard()
	{
		var drawn = cards.pop();
		updateNum();
		return drawn;
	}

	public function set(cards:Cards)
	{
		this.cards = cards;
		updateNum();
	}

	public function clearPile()
	{
		cards = [];
		updateNum();
	}

	public function shuffle()
	{
		GameController.rng.shuffle(cards);
	}

	public function new(x:Int = 0, y:Int = 0, color:FlxColor, ?pileName:String = 'unnamed pile')
	{
		super(x, y);
		cards = [];

		this.body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH, CARD_HEIGHT, color);
		ViewUtils.centerSprite(body);
		add(body);

		this.numCards = new FlxText(0, 0, 0, '${pileName}: ${cards.length}');
		numCards.setFormat(AssetPaths.DOSWin__ttf, BATTLE_UI_FONT_SIZE_SM, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(numCards, 0, -90);
		add(numCards);

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end

		this.pileName = pileName;
	}
}
