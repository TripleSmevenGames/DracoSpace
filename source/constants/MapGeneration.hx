package constants;

class MapGeneration
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
