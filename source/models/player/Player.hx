package models.player;

/** Represents the player itself outside of battle. Characters, inventory, skills, money, etc. **/
class Player
{
	public static var deck:Deck;
	public static var chars:Array<CharacterInfo> = [];
	public static var money:Int;
}
