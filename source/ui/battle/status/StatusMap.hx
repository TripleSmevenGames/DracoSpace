package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusType;
import ui.battle.status.enemyPassives.*;

class StatusMap
{
	public static var map:Map<StatusType, CharacterSprite->Status> = [
		BURN => (owner:CharacterSprite) -> new BurnStatus(owner),
		STATIC => (owner:CharacterSprite) -> new StaticStatus(owner),
		COLD => (owner:CharacterSprite) -> new ColdStatus(owner),
		ATTACK => (owner:CharacterSprite) -> new AttackStatus(owner),
		ATTACKDOWN => (owner:CharacterSprite) -> new AttackDownStatus(owner),
		TAUNT => (owner:CharacterSprite) -> new TauntStatus(owner),
		COUNTER => (owner:CharacterSprite) -> new CounterStatus(owner),
		DODGE => (owner:CharacterSprite) -> new DodgeStatus(owner),
		STUN => (owner:CharacterSprite) -> new StunStatus(owner),
		EXPOSED => (owner:CharacterSprite) -> new ExposedStatus(owner),
		//
		LASTBREATH => (owner:CharacterSprite) -> new LastBreathPassive(owner),
		DYINGWISH => (owner:CharacterSprite) -> new DyingWishPassive(owner),
		HAUNT => (owner:CharacterSprite) -> new HauntPassive(owner),
		CUNNING => (owner:CharacterSprite) -> new CunningPassive(owner),
		SIPHON => (owner:CharacterSprite) -> new SiphonPassive(owner),
		PETALARMOR => (owner:CharacterSprite) -> new PetalArmorPassive(owner),
		PETALSPIKES => (owner:CharacterSprite) -> new PetalSpikesPassive(owner),
		STURDY => (owner:CharacterSprite) -> new SturdyPassive(owner),
		PLUSDRAW => (owner:CharacterSprite) -> new PlusDraw(owner),
		MINUSDRAW => (owner:CharacterSprite) -> new MinusDraw(owner),
		WOUNDED => (owner:CharacterSprite) -> new WoundedStatus(owner),
		WEAK => (owner:CharacterSprite) -> new WeakStatus(owner),
	];
}
