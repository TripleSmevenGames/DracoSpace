package utils;

import flixel.FlxBasic;
import haxe.Exception;
import models.ai.BaseAI;
import models.player.CharacterInfo.CharacterType;
import models.skills.Skill.SkillPointCombination;
import substates.BattleSubState;
import ui.battle.CharacterSprite;
import ui.battle.DeckSprite;
import ui.battle.Hand;
import ui.battle.ITurnTriggerable;
import ui.battle.SkillSprite;
import ui.battle.status.Status;
import utils.battleManagerUtils.BattleContext;
import utils.battleManagerUtils.BattleSounds;

enum BattleManagerStateNames
{
	NONE;
	PLAYER_START;
	PLAYER_IDLE;
	PLAYER_ANIMATING_PLAY;
	PLAYER_TARGET;
	PLAYER_ANIMATING_SKILL;
	PLAYER_END;
	ENEMY_START;
	ENEMY_IDLE;
	ENEMY_ANIMATING_PLAY;
	ENEMY_TARGET;
	ENEMY_ANIMATING_SKILL;
	ENEMY_END;
	WIN;
	LOSE;
}

typedef BattleManagerState =
{
	var name:BattleManagerStateNames;
	var turn:CharacterType;
	var start:Void->Void; // switches to this state and does setup for the state.
	var update:Float->Void; // runs after every frame after start.
};

/** Manages turns, what happens at the start/end of turns, and interaction between player chars, player hand, and enemy chars. 
 *
 * This manager shouldn't try to do something that an object could just do itself, i.e. things that
 * do not involve outside objects.
**/
@:access(utils.SubStateManager)
class BattleManager extends FlxBasic
{
	var state:BattleManagerState;
	var bam:BattleAnimationManager;
	var bss:BattleSubState;
	var sounds:BattleSounds;

	var playerSkillSprites:Array<SkillSprite>;
	var enemySkillSprites:Array<SkillSprite>;

	var activeSkillSprite:SkillSprite;
	var activeTargets:Array<CharacterSprite>;

	/** The end turn button will flip this flag true when pressed. **/
	public var endTurnFlag(null, set):Bool = false;

	/** When an enemy char sprite dies, it should add to this number. **/
	public var enemyDiscardCards:Int = 0;

	public var context:BattleContext;

	/** something is "turnable" if it has something to trigger at the start or end of player or enemy turns. **/
	var turnables:Array<ITurnTriggerable>;

	var enemyAI:BaseAI;

	var playerStartState:BattleManagerState;
	var playerIdleState:BattleManagerState;
	var playerAnimatingPlayState:BattleManagerState;
	var playerTargetState:BattleManagerState;
	var playerAnimatingSkillState:BattleManagerState;
	var playerEndState:BattleManagerState;

	var enemyStartState:BattleManagerState;
	var enemyIdleState:BattleManagerState;
	var enemyAnimatingPlayState:BattleManagerState;
	var enemyTargetState:BattleManagerState;
	var enemyAnimatingSkillState:BattleManagerState;
	var enemyEndState:BattleManagerState;

	var winState:BattleManagerState;
	var loseState:BattleManagerState;

	public var turnCounter:Int;

	/** Set this to true to signal the BM to end the turn.
	 *
	 * Won't work if we are not in the idle phase, or if some animations are still playing.
	**/
	public function set_endTurnFlag(val:Bool)
	{
		if (!canEndTurn())
			return endTurnFlag = false;

		return endTurnFlag = val;
	}

	/** Get the name of state of the battle. Returns a BattleManagerStateName enum. **/
	public function getState()
	{
		if (state == null)
			return NONE;
		else
			return state.name;
	}

	/** Whose turn is it? **/
	public function getTurn()
	{
		if (state == null)
			return null;
		else
			return state.turn;
	}

	function canMoveToNextState()
	{
		return bam.isQueueEmpty() && !context.areCharacterHurtAnimationsPlaying();
	}

	public function canEndTurn()
	{
		return getState() == PLAYER_IDLE && canMoveToNextState();
	}

	// make all skill sprites visible and interactable,
	function showAllSkillSprites()
	{
		for (sprite in playerSkillSprites)
			sprite.revive();
		for (sprite in enemySkillSprites)
			sprite.revive();
		for (char in context.pChars)
			char.cancelSkillBtn.kill();
	}

	// make all skill sprites invisible and un-interactable
	function hideAllSkillSprites()
	{
		for (sprite in playerSkillSprites)
			sprite.kill();
		for (sprite in enemySkillSprites)
			sprite.kill();
	}

	function setTargetArrowsVisible(val:Bool, type:CharacterType)
	{
		var chars = context.getChars(type);
		for (char in chars)
		{
			char.targetArrow.visible = val;
			char.targetArrow.alpha = .5;
		}
	}

	// called during idle state, player is picking a skill to activate.
	function onSkillClick(skillSprite:SkillSprite)
	{
		if (getState() != PLAYER_IDLE)
			return;

		var skill = skillSprite.skill;
		if (skillSprite.disabled)
			return;

		var pDeck = context.pDeck;

		if (!skill.canPayWith(context.pDeck.getSkillPoints()))
		{
			pDeck.blinkSkillPointDisplay(); // warn the player they are short on points
			return;
		}

		var onlies = pDeck.getPickedCardsOnly();
		if (onlies.length != 0 && (onlies.length > 1 || onlies[0] != skillSprite.owner))
		{
			return; // trying to play cards with onlies on the wrong character
		}

		activeSkillSprite = skillSprite;
	}

	function cancelSkillTargeting()
	{
		if (getState() == PLAYER_TARGET)
		{
			playerIdleState.start();
		}
	}

	// called during target state, player is selecting a target for the current skill.
	function onCharacterClick(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET)
			activeTargets = [char];
	}

	function onCharacterOver(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET)
			char.targetArrow.alpha = 1;
	}

	function onCharacterOut(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET)
			char.targetArrow.alpha = .5;
	}

	/** Reset the manager for a new battle. Make sure you add() this to the state after the battle view has been setup. **/
	public function reset(playerDeckSprite:DeckSprite, enemyDeckSprite:DeckSprite, playerChars:Array<CharacterSprite>, enemyChars:Array<CharacterSprite>,
			?enemyAI:BaseAI)
	{
		this.revive();

		this.context = new BattleContext(playerDeckSprite, enemyDeckSprite, playerChars, enemyChars);
		this.playerSkillSprites = [];
		this.enemySkillSprites = [];
		this.turnables = [];

		for (char in playerChars)
		{
			turnables.push(char); // add all player chars to the list of turnables.
			char.setOnClickCancelSkill(cancelSkillTargeting);
			for (skillSprite in char.skillSprites)
			{
				playerSkillSprites.push(skillSprite);
				skillSprite.setOnClick(onSkillClick);
			}
		}

		for (char in enemyChars)
		{
			char.setOnClick(onCharacterClick);
			char.setOnHover(onCharacterOver, onCharacterOut);
			turnables.push(char); // add all enemy chars to the list of turnables.
			for (skillSprite in char.skillSprites)
			{
				enemySkillSprites.push(skillSprite);
			}
		}

		turnables.push(playerDeckSprite);
		turnables.push(enemyDeckSprite);

		this.enemyAI = enemyAI != null ? enemyAI : new BaseAI(enemySkillSprites, enemyDeckSprite, playerChars);

		turnCounter = 1;
		enemyDiscardCards = 0;

		playerStartState.start();
	}

	public function new()
	{
		super();
		this.bam = GameController.battleAnimationManager;
		this.bss = GameController.subStateManager.bss;
		this.sounds = new BattleSounds();

		/**--------------DEFINE ALL THE STATES-----------**/
		/**                                              **/

		// trigger stuff in this state. Player can't act.
		this.playerStartState = {
			name: PLAYER_START,
			turn: PLAYER,
			start: () ->
			{
				state = playerStartState;

				sounds.startPlayerTurn.play();
				turnCounter++;

				showAllSkillSprites();

				for (turnable in this.turnables)
					turnable.onPlayerStartTurn(context);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState()) // wait for animations to finish
				{
					playerIdleState.start();
				}
			}
		};

		// Do some checks. Otherwise, player can pick cards, play skills, or end their turn.
		this.playerIdleState = {
			name: PLAYER_IDLE,
			turn: PLAYER,
			start: () ->
			{
				state = playerIdleState;

				showAllSkillSprites();

				// reset this stuff
				activeSkillSprite = null;
				activeTargets = null;
				setTargetArrowsVisible(false, PLAYER);
				setTargetArrowsVisible(false, ENEMY);

				// check if we've won or lost
				if (context.areAllCharsDead(ENEMY))
				{
					winState.start();
				}
				else if (context.areAllCharsDead(PLAYER))
				{
					loseState.start();
				}
			},
			update: (elapsed:Float) ->
			{
				// check if something caused the enemy to discard cards
				if (enemyDiscardCards > 0)
				{
					context.eDeck.discardRandomCards(enemyDiscardCards);
					enemyDiscardCards = 0;
				}
				else
				{
					if (activeSkillSprite != null)
					{
						playerAnimatingPlayState.start();
					}
					else if (endTurnFlag && canEndTurn())
					{
						playerEndState.start();
						endTurnFlag = false;
					}
				}
			},
		};

		// Animate the cards being played. Player can't act.
		this.playerAnimatingPlayState = {
			name: PLAYER_ANIMATING_PLAY,
			turn: PLAYER,
			start: () ->
			{
				if (activeSkillSprite == null)
					throw new Exception('entered animating play state, but no skill was active');

				state = playerAnimatingPlayState;
				context.pDeck.playPickedCards(activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState())
					playerTargetState.start();
			},
		};

		// Let player select a target for their played skill, if possible. Player can't do anything else.
		this.playerTargetState = {
			name: PLAYER_TARGET,
			turn: PLAYER,
			start: () ->
			{
				state = playerTargetState;

				if (activeSkillSprite == null)
					throw new Exception('entered target state, but no skill was active');

				activeTargets = null;

				// Either auto choose the targets, or show the target arrows and let the targets be chosen.
				switch (activeSkillSprite.skill.targetMethod)
				{
					case SINGLE_ENEMY:
						var aliveEnemies = context.getAliveEnemies();
						if (aliveEnemies.length == 1)
						{
							activeTargets = aliveEnemies; // auto choose the only enemy left
							return;
						}
						else
						{
							setTargetArrowsVisible(true, ENEMY);
							hideAllSkillSprites();
							activeSkillSprite.owner.cancelSkillBtn.revive();
							return; // wait for user selection.
						}
					case ALL_ENEMY:
						var aliveEnemies = context.getAliveEnemies();
						activeTargets = aliveEnemies;
					case SINGLE_ALLY:
						setTargetArrowsVisible(true, PLAYER);
						hideAllSkillSprites();
						activeSkillSprite.owner.cancelSkillBtn.revive();
						return; // wait for user selection.
					case ALL_ALLY:
						activeTargets = context.pChars;
					case SELF, DECK:
						activeTargets = [activeSkillSprite.owner];
					default:
						throw new Exception('bad target state');
				}
			},
			update: (elapsed:Float) ->
			{
				if (activeTargets != null)
				{
					playerAnimatingSkillState.start();
				}
			},
		};

		this.playerAnimatingSkillState = {
			name: PLAYER_ANIMATING_SKILL,
			turn: PLAYER,
			start: () ->
			{
				this.state = playerAnimatingSkillState;

				// remove the cancel button and all target arrows
				activeSkillSprite.owner.cancelSkillBtn.kill();
				setTargetArrowsVisible(false, PLAYER);
				setTargetArrowsVisible(false, ENEMY);

				// play the skill
				activeSkillSprite.owner.playSkill(activeSkillSprite, activeTargets, context);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState())
					playerIdleState.start();
			},
		}

		// Trigger some stuff. Player can't act.
		this.playerEndState = {
			name: PLAYER_END,
			turn: PLAYER,
			start: () ->
			{
				state = playerEndState;

				sounds.endPlayerTurn.play();

				for (turnable in this.turnables)
					turnable.onPlayerEndTurn(context);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState()) // wait for animations to finish before enemy's turn start
					enemyStartState.start();
			}
		};

		this.enemyStartState = {
			name: ENEMY_START,
			turn: PLAYER,
			start: () ->
			{
				state = enemyStartState;
				for (turnable in this.turnables)
					turnable.onEnemyStartTurn(context);

				// call all the enemy's things' onStartTurn
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState()) // wait for animations to finish
				{
					enemyIdleState.start();
				}
			}
		};

		this.enemyIdleState = {
			name: ENEMY_START,
			turn: ENEMY,
			start: () ->
			{
				state = enemyIdleState;

				activeSkillSprite = null;
				activeTargets = null;

				if (context.areAllCharsDead(ENEMY))
				{
					winState.start();
				}
				else if (context.areAllCharsDead(PLAYER))
				{
					loseState.start();
				}
			},
			update: (elapsed:Float) ->
			{
				if (enemyDiscardCards > 0)
				{
					context.eDeck.discardRandomCards(enemyDiscardCards);
					enemyDiscardCards = 0;
				}
				else
				{
					var decidedSkill = enemyAI.decideSkill();
					if (decidedSkill == null) // no skills left for the enemy to play. End turn.
					{
						enemyEndState.start();
					}
					else
					{
						activeSkillSprite = decidedSkill;
						enemyAnimatingPlayState.start();
					}
				}
			}
		};

		this.enemyAnimatingPlayState = {
			name: ENEMY_ANIMATING_PLAY,
			turn: ENEMY,
			start: () ->
			{
				if (activeSkillSprite == null)
				{
					throw new Exception('entered animating play state, but no skill was active');
				}
				state = enemyAnimatingPlayState;
				var cards = enemyAI.pickCardsForSkill(activeSkillSprite);
				context.eDeck.playCards(cards, activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState())
					enemyTargetState.start();
			},
		};

		this.enemyTargetState = {
			name: ENEMY_TARGET,
			turn: ENEMY,
			start: () ->
			{
				state = enemyTargetState;
				activeTargets = enemyAI.decideTargetsForSkill(activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (activeTargets != null)
				{
					enemyAnimatingSkillState.start();
				}
			},
		}

		this.enemyAnimatingSkillState = {
			name: ENEMY_ANIMATING_SKILL,
			turn: ENEMY,
			start: () ->
			{
				this.state = enemyAnimatingSkillState;

				activeSkillSprite.owner.playSkill(activeSkillSprite, activeTargets, context);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState())
					enemyIdleState.start();
			},
		}

		this.enemyEndState = {
			name: ENEMY_END,
			turn: ENEMY,
			start: () ->
			{
				state = enemyEndState;

				for (turnable in this.turnables)
					turnable.onEnemyEndTurn(context);
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState()) // wait for animations to finish before player's turn start
					playerStartState.start();
			}
		};

		this.winState = {
			name: WIN,
			turn: NONE,
			start: () ->
			{
				this.state = winState;
				bss.showWinScreen();
			},
			update: (elapsed:Float) -> {}
		};

		this.loseState = {
			name: LOSE,
			turn: NONE,
			start: () ->
			{
				this.state = loseState;
				bss.showLoseScreen(); // change this to lose screen
			},
			update: (elapsed:Float) -> {}
		};
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (state != null)
			state.update(elapsed);
	}
}
