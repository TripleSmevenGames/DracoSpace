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
		EXHAUST => (owner:CharacterSprite) -> new ExhaustStatus(owner),
		// EXPOSED => () -> new TauntStatus(owner),
		LASTBREATH => (owner:CharacterSprite) -> new LastBreathPassive(owner),
		DYINGWISH => (owner:CharacterSprite) -> new DyingWishPassive(owner),
		CUNNING => (owner:CharacterSprite) -> new CunningPassive(owner),
		OBSERVATION => (owner:CharacterSprite) -> new ObservationPassive(owner),
		PETALARMOR => (owner:CharacterSprite) -> new PetalArmorPassive(owner),
		PETALSPIKES => (owner:CharacterSprite) -> new PetalSpikesPassive(owner),
		PLUSDRAW => (owner:CharacterSprite) -> new PlusDraw(owner),
		MINUSDRAW => (owner:CharacterSprite) -> new MinusDraw(owner),
	];
}
