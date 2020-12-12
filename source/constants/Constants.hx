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
}

class UIMeasurements
{
	public static inline final CARD_WIDTH = 100;
	public static inline final CARD_HEIGHT = 140;
	public static inline final CARD_FONT_SIZE = 12;

	public static inline final BATTLE_UI_FONT_SIZE_SM = 16;
}
