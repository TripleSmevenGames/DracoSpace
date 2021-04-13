package utils;

import flixel.FlxG;
import flixel.math.FlxRandom;
import haxe.Exception;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;

// utility functions and globals for game logic.
class GameUtils
{
	public static var random:FlxRandom = new FlxRandom();

	public static function weightedPick<T>(items:Array<T>, weights:Array<Float>)
	{
		if (items.length != weights.length)
		{
			throw new Exception('items and weights not same length');
		}
		return items[GameController.rng.weightedPick(weights)];
	}

	// potential to be slow? 1 loop iterating through cards, another when calling .sum()

	/** Get the total skill point value of the array of Cards**/
	public static function getSkillPointTotal(cards:Array<Card>)
	{
		var cardSkillPoints = new Array<SkillPointCombination>();
		for (card in cards)
			cardSkillPoints.push(card.skillPoints);
		return SkillPointCombination.sum(cardSkillPoints);
	}

	public static function getRandomChoice<T>(array:Array<T>)
	{
		var choice = random.int(0, array.length - 1);
		return array[choice];
	}

	public static function smallCameraShake()
	{
		FlxG.camera.shake(0.01, 0.05);
	}

	public static function mediumCameraShake()
	{
		FlxG.camera.shake(0.1, 0.1);
	}

	public static function bigCameraShake()
	{
		FlxG.camera.shake(.3, 0.5);
	}
}
