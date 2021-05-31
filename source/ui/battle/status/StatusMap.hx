package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusType;
import ui.battle.status.enemyPassives.*;

class StatusMap
{
	public static var map:Map<StatusType, (CharacterSprite, Int) -> Status> = [
		BURN => (owner:CharacterSprite, initialStacks:Int = 1) -> new BurnStatus(owner, initialStacks),
		STATIC => (owner:CharacterSprite, initialStacks:Int = 1) -> new StaticStatus(owner, initialStacks),
		COLD => (owner:CharacterSprite, initialStacks:Int = 1) -> new ColdStatus(owner, initialStacks),
		ATTACK => (owner:CharacterSprite, initialStacks:Int = 1) -> new AttackStatus(owner, initialStacks),
		ATTACKDOWN => (owner:CharacterSprite, initialStacks:Int = 1) -> new AttackDownStatus(owner, initialStacks),
		TAUNT => (owner:CharacterSprite, initialStacks:Int = 1) -> new TauntStatus(owner, initialStacks),
		COUNTER => (owner:CharacterSprite, initialStacks:Int = 1) -> new CounterStatus(owner, initialStacks),
		DODGE => (owner:CharacterSprite, initialStacks:Int = 1) -> new DodgeStatus(owner, initialStacks),
		STUN => (owner:CharacterSprite, initialStacks:Int = 1) -> new StunStatus(owner, initialStacks),
		EXPOSED => (owner:CharacterSprite, initialStacks:Int = 1) -> new ExposedStatus(owner, initialStacks),
		//
		LASTBREATH => (owner:CharacterSprite, initialStacks:Int = 1) -> new LastBreathPassive(owner, initialStacks),
		DYINGWISH => (owner:CharacterSprite, initialStacks:Int = 1) -> new DyingWishPassive(owner, initialStacks),
		HAUNT => (owner:CharacterSprite, initialStacks:Int = 1) -> new HauntPassive(owner, initialStacks),
		CUNNING => (owner:CharacterSprite, initialStacks:Int = 1) -> new CunningPassive(owner, initialStacks),
		SIPHON => (owner:CharacterSprite, initialStacks:Int = 1) -> new SiphonPassive(owner, initialStacks),
		PETALARMOR => (owner:CharacterSprite, initialStacks:Int = 1) -> new PetalArmorPassive(owner, initialStacks),
		PETALSPIKES => (owner:CharacterSprite, initialStacks:Int = 1) -> new PetalSpikesPassive(owner, initialStacks),
		STURDY => (owner:CharacterSprite, initialStacks:Int = 1) -> new SturdyPassive(owner, initialStacks),
		PLUSDRAW => (owner:CharacterSprite, initialStacks:Int = 1) -> new PlusDraw(owner, initialStacks),
		MINUSDRAW => (owner:CharacterSprite, initialStacks:Int = 1) -> new MinusDraw(owner, initialStacks),
		WOUNDED => (owner:CharacterSprite, initialStacks:Int = 1) -> new WoundedStatus(owner, initialStacks),
		WEAK => (owner:CharacterSprite, initialStacks:Int = 1) -> new WeakStatus(owner, initialStacks),
	];
}
