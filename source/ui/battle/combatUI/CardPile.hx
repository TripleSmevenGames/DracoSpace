package ui.battle.combatUI;

import constants.Fonts;
import constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;
import utils.GameController;
import utils.GameUtils;
import utils.ViewUtils;

/** represents either a drawpile or discard pile during battle. Or maybe another pile in the future (exiled cards?)
 * used with DeckSprite. Centered.
 */
class CardPile extends FlxSpriteGroup
{
	public var cards(null, null):Cards;

	var body:BattleIndicatorIcon;
	var pileName:String;
	var deck:Deck;

	// showing how many cards this deck draws per turn (for enemy probably)
	var subtitle:FlxText;
	var subtitleBackground:FlxSprite;

	inline function updateNum()
	{
		body.updateDisplay(Std.string(cards.length));
	}

	public function updateDraw(val:Int)
	{
		subtitle.text = 'Draw: $val';
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

	/** Name should be 'Draw' or 'Discard'. **/
	public function new(pileName:String = 'unnamed pile')
	{
		super();
		cards = [];

		this.body = new BattleIndicatorIcon(AssetPaths.cardsIcon__png, pileName, null, {color: FlxColor.WHITE, centered: true});
		add(body);
		this.pileName = pileName;

		if (pileName == 'Draw')
		{
			this.subtitle = new FlxText(0, 0, 0, 'Draw: 0');
			subtitle.setFormat(Fonts.NUMBERS_FONT, BATTLE_UI_FONT_SIZE_LG, FlxColor.WHITE, FlxTextAlign.CENTER);

			var xPos = 0;
			var yPos = body.height / 2 + subtitle.height / 2;
			ViewUtils.centerSprite(subtitle, xPos, yPos);
			add(subtitle);

			this.subtitleBackground = new FlxSprite();
			subtitleBackground.makeGraphic(Std.int(body.width), 24, FlxColor.fromRGB(0, 0, 0, 128));
			ViewUtils.centerSprite(subtitleBackground, xPos, yPos);
			add(subtitleBackground);
		}
	}
}
