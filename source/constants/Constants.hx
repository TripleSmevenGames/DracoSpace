package constants;

class MapGenerationConsts
{
	// nodes per column change
	public static final NUM_NODE_CHANCE_ITEMS = [2, 3, 4];
	public static final NUM_NODE_CHANCE_WEIGHTS:Array<Float> = [60, 30, 10];

	// node type stuff
	public static final NODE_TYPE_CHANCE_ITEMS = ['BATTLE', 'TREASURE', 'CHOICE', 'REST'];
	public static final NODE_TYPE_CHANCE_WEIGHTS:Array<Float> = [60, 5, 15, 10];
	public static inline final MIN_BATTLES = 20;
	public static inline final MIN_CHOICES = 8;
	public static inline final TREASURES_IN_FIRST_HALF = 1;
	public static inline final TREASURES_IN_SECOND_HALF = 1;
	public static inline final ELITES_IN_SECOND_HALF = 2;
}

class UIMeasurements
{
	public static inline final CARD_WIDTH = 100;
	public static inline final CARD_HEIGHT = 140;
	public static inline final CARD_FONT_SIZE = 12;

	public static inline final BATTLE_UI_FONT_SIZE_SM = 14;
	public static inline final BATTLE_UI_FONT_SIZE_MED = 18;
	public static inline final BATTLE_UI_FONT_SIZE_LG = 24;
}

class Colors
{
	public static inline final BACKGROUND_BLUE = 0xFF001840;
	public static inline final DARK_BLUE = 0xFF004070;
	public static inline final DARK_RED = 0xFF850000;
	public static inline final DARK_GREEN = 0xFF008000;
	public static inline final DARK_YELLOW = 0xFFBFBC00;
	public static inline final DARK_PURPLE = 0xFF330080;
	public static inline final DARK_GRAY = 0xFF454545;
}

class Description
{
	public static inline final BURN_DESC = "Burn X: At the end of turn, take X damage and lose 1 stack. 
		If this character didn't play cards this turn, deal the same damage to its allies.";
}
