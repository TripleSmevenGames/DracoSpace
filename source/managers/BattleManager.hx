package managers;

import flixel.FlxBasic;
import haxe.Exception;
import models.CharacterInfo;
import models.ai.BaseAI;
import models.ai.EnemyIntentMaker;
import models.events.GameEvent;
import models.player.Player;
import substates.BattleSubState;
import ui.battle.IBattleTriggerable;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;
import utils.battleManagerUtils.BattleUISounds;
import utils.battleManagerUtils.RewardHelper;

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
@:access(managers.SubStateManager)
class BattleManager extends FlxBasic
{
	var state:BattleManagerState;
	var bam:BattleAnimationManager;
	var bss:BattleSubState;
	var sounds:BattleUISounds;

	var playerSkillSprites:Array<SkillSprite>;
	var enemySkillSprites:Array<SkillSprite>;

	/** The skill soon to be played, both during enemy and player turns.**/
	var activeSkillSprite:SkillSprite;

	/** The targets that the active skill will target (for both enemy and player turns)**/
	var activeTargets:Array<CharacterSprite>;

	/** The available targets for the current active skill, when the player is choosing their target.**/
	var availableTargets:Array<CharacterSprite>;

	/** The end turn button will flip this flag true when pressed. **/
	public var endTurnFlag(null, set):Bool = false;

	public var context:BattleContext;
	public var battleType:GameEventType;

	var enemyAI:BaseAI;
	var currentIntents:Array<Intent>;
	var activeIntent:Intent;

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
		return (getState() == PLAYER_IDLE) && canMoveToNextState();
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

	function playAllCharIdle()
	{
		for (char in context.pChars)
			char.playIdle();
		for (char in context.eChars)
			char.playIdle();
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
			// pDeck.blinkSkillPointDisplay(); // warn the player they are short on points
			// play some sound instead
			sounds.error.play();
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
			// playerIdleState.start();
			// return your spent cards
		}
	}

	/** Check if any characters are dead, and put the xCover over their avatar if so**/
	function checkDead()
	{
		if (context != null)
		{
			context.pDeck.checkDead();
			context.eDeck.checkDead();
		}
	}

	function isCharacterTargetable(char:CharacterSprite)
	{
		return availableTargets.contains(char) && !char.dead;
	}

	// called during target state, player is selecting a target for the current skill.
	function onCharacterClick(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET && isCharacterTargetable(char))
			activeTargets = [char];
	}

	function onCharacterOver(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET && isCharacterTargetable(char))
			char.targetArrow.alpha = 1;
	}

	function onCharacterOut(char:CharacterSprite)
	{
		if (getState() == PLAYER_TARGET && isCharacterTargetable(char))
			char.targetArrow.alpha = .5;
	}

	function onAnyPlaySkill(skillSprite:SkillSprite)
	{
		for (enemy in context.eChars)
			enemy.onAnyPlaySkill(skillSprite, context);

		for (player in context.pChars)
			player.onAnyPlaySkill(skillSprite, context);
	}

	/** Reset the manager for a new battle. Make sure you add() this to the state after the battle view has been setup. **/
	public function reset(context:BattleContext, ?enemyAI:BaseAI, ?battleType:GameEventType = BATTLE)
	{
		this.revive();

		this.context = context;
		this.battleType = battleType;
		this.playerSkillSprites = [];
		this.enemySkillSprites = [];

		for (char in context.pChars)
		{
			char.context = context;
			char.setOnClick(onCharacterClick);
			char.setOnHover(onCharacterOver, onCharacterOut);
			char.setOnClickCancelSkill(cancelSkillTargeting);
			for (skillSprite in char.skillSprites)
			{
				playerSkillSprites.push(skillSprite);
				skillSprite.setOnClick(onSkillClick);
			}
		}

		for (char in context.eChars)
		{
			char.context = context;
			char.setOnClick(onCharacterClick);
			char.setOnHover(onCharacterOver, onCharacterOut);
			for (skillSprite in char.skillSprites)
			{
				enemySkillSprites.push(skillSprite);
			}
		}

		this.enemyAI = enemyAI != null ? enemyAI : new BaseAI(enemySkillSprites, context);

		playerStartState.start();
	}

	public function new()
	{
		super();
		this.bam = GameController.battleAnimationManager;
		this.bss = GameController.subStateManager.bss;
		this.sounds = new BattleUISounds();

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
				context.turnCounter++;

				showAllSkillSprites();

				for (turnTriggerable in this.context.turnTriggerables)
					turnTriggerable.onPlayerStartTurn(context);

				enemyAI.generateNewSeedForTurn();

				context.pDeck.highlightHandTitle();
				context.eDeck.unhighlightHandTitle();
			},
			update: (elapsed:Float) ->
			{
				if (canMoveToNextState()) // wait for animations to finish
				{
					playerIdleState.start();
				}
			}
		};

		// Do some checks like if characters are dead or not.
		// Otherwise, player can pick cards, play skills, or end their turn.
		this.playerIdleState = {
			name: PLAYER_IDLE,
			turn: PLAYER,
			start: () ->
			{
				state = playerIdleState;

				showAllSkillSprites();
				playAllCharIdle();

				// reset this stuff
				activeSkillSprite = null;
				activeTargets = null;
				availableTargets = [];
				setTargetArrowsVisible(false, PLAYER);
				setTargetArrowsVisible(false, ENEMY);

				// redecide moves here and render the intent sprites.
				// it uses the same seed for its RNG, so if all conditions are the same, it should decide on the same moves every time.
				// this part MIGHT be slow, there's a lot of rerendering inside the same frame.
				this.currentIntents = enemyAI.decideIntents();
				for (char in context.eChars)
					char.resetIntents();
				for (intent in currentIntents)
				{
					if (intent.skill != null)
						intent.skill.owner.addIntent(intent);
				}

				// mark any dead characters as dead, by putting the xCover over their avatar
				checkDead();

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
				if (activeSkillSprite != null)
				{
					playerAnimatingPlayState.start();
				}
				else if (endTurnFlag && canEndTurn())
				{
					playerEndState.start();
					endTurnFlag = false;
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
							availableTargets = context.getAliveEnemies();
							hideAllSkillSprites();
							activeSkillSprite.owner.cancelSkillBtn.revive();
							return; // wait for user selection.
						}
					case ALL_ENEMY:
						var aliveEnemies = context.getAliveEnemies();
						activeTargets = aliveEnemies;
					case RANDOM_ENEMY: // for a single random enemy. For multiple random enemies, make the skill ALL_ENEMY and calculate targets itself.
						activeTargets = [context.getRandomTarget(ENEMY)];
					case SINGLE_ALLY:
						setTargetArrowsVisible(true, PLAYER);
						hideAllSkillSprites();
						availableTargets = context.getAlivePlayers();
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
				// trigger any characters' onAnyPlaySkill
				onAnyPlaySkill(activeSkillSprite);
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

				for (turnTriggerable in this.context.turnTriggerables)
					turnTriggerable.onPlayerEndTurn(context);
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
				for (turnTriggerable in this.context.turnTriggerables)
					turnTriggerable.onEnemyStartTurn(context);

				this.currentIntents = enemyAI.decideIntents(); // decide the intents again
				context.eDeck.highlightHandTitle();
				context.pDeck.unhighlightHandTitle();
			},
			update: (elapsed:Float) ->
			{
				// wait for animations to finish
				if (canMoveToNextState())
				{
					// mark any dead characters as dead, by putting the xCover over their avatar
					checkDead();

					// check if we've won or lost
					if (context.areAllCharsDead(ENEMY))
					{
						winState.start();
					}
					else if (context.areAllCharsDead(PLAYER))
					{
						loseState.start();
					}
					else
					{
						enemyIdleState.start();
					}
				}
			}
		};

		this.enemyIdleState = {
			name: ENEMY_START,
			turn: ENEMY,
			start: () ->
			{
				state = enemyIdleState;

				playAllCharIdle();

				// mark any dead characters as dead, by putting the xCover over their avatar
				checkDead();

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
				if (currentIntents.length != 0) // there are still intents left in the decided intents. Play them out.
				{
					activeIntent = enemyAI.getNextIntent();
					activeSkillSprite = activeIntent.skill;
					enemyAnimatingPlayState.start();
				}
				else // there are no more decided intents. Try to create one more list of intents. If there's still nothing to do, give up and end turn.
				{
					this.currentIntents = enemyAI.decideIntents();
					if (this.currentIntents.length == 0)
						enemyEndState.start();
					else
					{
						activeIntent = enemyAI.getNextIntent();
						activeSkillSprite = activeIntent.skill;
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
				var cards = activeIntent.cardsToPlay;
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
				activeTargets = activeIntent.targets;
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
				onAnyPlaySkill(activeSkillSprite);
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

				for (turnTriggerable in this.context.turnTriggerables)
					turnTriggerable.onEnemyEndTurn(context);
			},
			update: (elapsed:Float) ->
			{
				// wait for animations to finish before player's turn start
				if (canMoveToNextState())
				{
					// mark any dead characters as dead, by putting the xCover over their avatar
					checkDead();

					// check if we've won or lost
					if (context.areAllCharsDead(ENEMY))
					{
						winState.start();
					}
					else if (context.areAllCharsDead(PLAYER))
					{
						loseState.start();
					}
					else
					{
						playerStartState.start();
					}
				}
			}
		};

		this.winState = {
			name: WIN,
			turn: NONE,
			start: () ->
			{
				this.state = winState;

				// get exp reward
				var expReward = RewardHelper.getExpReward(battleType);
				Player.exp += expReward;

				// get money reward
				var moneyReward = RewardHelper.getMoneyReward(battleType);
				Player.money += moneyReward;

				// show the win screen, which contains the rewards screen.
				bss.showWinScreen(expReward, moneyReward, battleType);
			},
			update: (elapsed:Float) -> {}
		};

		this.loseState = {
			name: LOSE,
			turn: NONE,
			start: () ->
			{
				this.state = loseState;
				bss.showLoseScreen();
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
