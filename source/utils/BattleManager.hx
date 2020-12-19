package utils;

import models.player.CharacterInfo.CharacterType;
import flixel.FlxBasic;
import haxe.Exception;
import models.ai.BaseAI;
import models.skills.Skill.SkillPointCombination;
import substates.BattleSubState;
import ui.battle.CharacterSprite;
import ui.battle.DeckSprite;
import ui.battle.Hand;
import ui.battle.ITurnable;
import ui.battle.SkillSprite;
import utils.BattleAnimationManager.BattleAnimation;

enum BattleManagerStateNames
{
	NONE;
	PLAYER_START;
	PLAYER_IDLE;
	PLAYER_ANIMATING_PLAY;
	PLAYER_TARGET;
	PLAYER_END;
	ENEMY_START;
	ENEMY_IDLE;
	ENEMY_ANIMATING_PLAY;
	ENEMY_TARGET;
	ENEMY_END;
	WIN;
	LOSE;
}

typedef BattleManagerStateOptions =
{
	var ?skillSprite:SkillSprite;
};

typedef BattleManagerState =
{
	var name:BattleManagerStateNames;
	var turn:CharacterType;
	var start:?BattleManagerStateOptions->Void; // switches to this state and does setup for the state.
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

	/** How many skill points the player has based on the cards they've picked from their hand.
		This should get set by the player's Skillpoint display.
	**/
	public var playerSkillPoints:SkillPointCombination;

	var activePlayAnim:Array<BattleAnimation>;
	var activeSkillSprite:SkillSprite;
	var activeTargets:Array<CharacterSprite>;

	/** The end turn button will flip this flag when pressed. **/
	public var endTurnFlag(null, set):Bool;

	var playerDeckSprite:DeckSprite;
	var enemyDeckSprite:DeckSprite;
	var playerChars:Array<CharacterSprite>;
	var enemyChars:Array<CharacterSprite>;

	/** something is "turnable" if it has something to trigger at the start or end of player or enemy turns. **/
	var turnables:Array<ITurnable>;

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

	public function canEndTurn()
	{
		return getState() == PLAYER_IDLE && bam.isQueueEmpty();
	}

	// make all skill sprites visible and interactable
	function showAllSkillSprites()
	{
		for (sprite in playerSkillSprites)
			sprite.revive();
		for (sprite in enemySkillSprites)
			sprite.revive();
	}

	// make all skill sprites invisible and un-interactable
	function hideAllSkillSprites()
	{
		for (sprite in playerSkillSprites)
			sprite.kill();
		for (sprite in enemySkillSprites)
			sprite.kill();
	}

	function setTargetArrowsVisible(val:Bool, type:CharacterType) {
		if (type == ENEMY) {
			for (char in enemyChars)
			{
				char.targetArrow.visible = val;
				char.targetArrow.alpha = .3;
			}
		} else if (type == PLAYER) {
			for (char in playerChars)
			{
				char.targetArrow.visible = val;
				char.targetArrow.alpha = .3;
			}
		}
	}

	// called during idle state, player is picking a skill to activate.
	function onSkillClick(skillSprite:SkillSprite)
	{
		if (getState() != PLAYER_IDLE)
			return;

		var skill = skillSprite.skill;
		if (!skill.canPayWith(playerSkillPoints))
		{
			playerDeckSprite.blinkSkillPointDisplay(); // warn the player they are short on points
			return;
		}
		else if (skillSprite.disabled)
		{
			return;
		}
		else
		{
			activeSkillSprite = skillSprite;
		}
	}

	// called during target state, player is selecting a target for the current skill.
	function onCharacterClick(char:CharacterSprite) {
		if (getState() != PLAYER_TARGET)
			return;

		activeTargets = [char];
	}

	function onCharacterOver(char:CharacterSprite) {
		if (getState() != PLAYER_TARGET)
			return;

		char.targetArrow.alpha = 1;
	}

	function onCharacterOut(char:CharacterSprite) {
		if (getState() != PLAYER_TARGET)
			return;

		char.targetArrow.alpha = .3;
	}

	function areAllCharsDead(type:CharacterType)
	{
		var chars:Array<CharacterSprite> = [];
		if (type == ENEMY)
			chars = enemyChars;
		if (type == PLAYER)
			chars = playerChars;

		for (char in chars)
		{
			if (!char.dead)
				return false;
		}
		return true;
	}

	function getAliveEnemies() {
		var aliveEnemies:Array<CharacterSprite> = [];
		for (char in enemyChars) {
			if (!char.dead)
				aliveEnemies.push(char);
		}
		return aliveEnemies;
	}

	/** Reset the manager for a new battle. Make sure you add() this to the state after the battle view has been setup. **/
	public function reset(playerDeckSprite:DeckSprite, enemyDeckSprite:DeckSprite, playerChars:Array<CharacterSprite>, enemyChars:Array<CharacterSprite>,
			?enemyAI:BaseAI)
	{
		this.revive();

		this.playerDeckSprite = playerDeckSprite;
		this.enemyDeckSprite = enemyDeckSprite;
		this.playerChars = playerChars;
		this.enemyChars = enemyChars;
		this.playerSkillSprites = [];
		this.enemySkillSprites = [];
		this.turnables = [];

		for (char in playerChars)
		{
			turnables.push(char); // add all player chars to the list of turnables.
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

		this.playerSkillPoints = new SkillPointCombination();
		turnCounter = 1;
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

		this.playerStartState = {
			name: PLAYER_START,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = playerStartState;

				sounds.startPlayerTurn.play();
				turnCounter++;

				for (turnable in this.turnables)
					turnable.onPlayerStartTurn();
			},
			update: (elapsed:Float) ->
			{
				if (bam.isQueueEmpty()) // wait for animations to finish
				{
					playerIdleState.start();
				}
			}
		};

		this.playerIdleState = {
			name: PLAYER_IDLE,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = playerIdleState;

				showAllSkillSprites();

				// reset this stuff
				activePlayAnim = null;
				activeSkillSprite = null;
				activeTargets = null;
				setTargetArrowsVisible(false, PLAYER);
				setTargetArrowsVisible(false, ENEMY);
			},
			update: (elapsed:Float) ->
			{
				if (areAllCharsDead(ENEMY))
				{
					winState.start();
				}
				else if (areAllCharsDead(PLAYER))
				{
					loseState.start();
				}
				else
				{
					if (activeSkillSprite != null)
					{
						playerAnimatingPlayState.start();
					}
					else if (endTurnFlag)
					{
						playerEndState.start();
						endTurnFlag = false;
					}
				}
			},
		};

		this.playerAnimatingPlayState = {
			name: PLAYER_ANIMATING_PLAY,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				if (activeSkillSprite == null)
					throw new Exception('entered animating play state, but no skill was active');

				state = playerAnimatingPlayState;
				activePlayAnim = this.playerDeckSprite.playPickedCards(activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (activePlayAnim != null && activePlayAnim.length == 0) // this will be true when the play animation is done playing.
					playerTargetState.start();
			},
		};

		this.playerTargetState = {
			name: PLAYER_TARGET,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = playerTargetState;

				if (activeSkillSprite == null)
					throw new Exception('entered target state, but no skill was active');

				activeTargets = null;
				hideAllSkillSprites();

				switch (activeSkillSprite.skill.targetMethod)
				{
					case SINGLE_ENEMY:
						var aliveEnemies = getAliveEnemies();
						if (aliveEnemies.length == 1)
						{
							activeTargets = aliveEnemies; // auto choose the only enemy left
							return;
						}
						else
						{
							setTargetArrowsVisible(true, ENEMY);
							return; // wait for user selection.
						}
					case SINGLE_ALLY:
						setTargetArrowsVisible(true, PLAYER);
					case SELF:
						activeTargets = [activeSkillSprite.owner];
					default:
						return;
				}
			},
			update: (elapsed:Float) ->
			{
				if (activeTargets != null)
				{
					activeSkillSprite.runEffect(activeTargets);
					playerIdleState.start();
				}
			},
		};

		this.playerEndState = {
			name: PLAYER_END,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = playerEndState;

				sounds.endPlayerTurn.play();

				for (turnable in this.turnables)
					turnable.onPlayerEndTurn();
			},
			update: (elapsed:Float) ->
			{
				if (bam.isQueueEmpty()) // wait for animations to finish before enemy's turn start
					enemyStartState.start();
			}
		};

		this.enemyStartState = {
			name: ENEMY_START,
			turn: PLAYER,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = enemyStartState;
				for (turnable in this.turnables)
					turnable.onEnemyStartTurn();

				// call all the enemy's things' onStartTurn
			},
			update: (elapsed:Float) ->
			{
				if (bam.isQueueEmpty()) // wait for animations to finish
				{
					enemyIdleState.start();
				}
			}
		};

		this.enemyIdleState = {
			name: ENEMY_START,
			turn: ENEMY,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = enemyIdleState;

				activePlayAnim = null;
				activeSkillSprite = null;
				activeTargets = null;
			},
			update: (elapsed:Float) ->
			{
				if (areAllCharsDead(ENEMY))
				{
					winState.start();
				}
				else if (areAllCharsDead(PLAYER))
				{
					loseState.start();
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
			start: (?options:BattleManagerStateOptions) ->
			{
				if (activeSkillSprite == null)
				{
					throw new Exception('entered animating play state, but no skill was active');
				}
				state = enemyAnimatingPlayState;
				var cards = enemyAI.pickCardsForSkill(activeSkillSprite);
				activePlayAnim = this.enemyDeckSprite.playCards(cards, activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (activePlayAnim != null && activePlayAnim.length == 0) // this will be true when the play animation is done playing.
					enemyTargetState.start();
			},
		};

		this.enemyTargetState = {
			name: ENEMY_TARGET,
			turn: ENEMY,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = enemyTargetState;
				activeTargets = enemyAI.decideTargetsForSkill(activeSkillSprite);
			},
			update: (elapsed:Float) ->
			{
				if (activeTargets != null)
				{
					activeSkillSprite.runEffect(activeTargets);
					enemyIdleState.start();
				}
			},
		}

		this.enemyEndState = {
			name: ENEMY_END,
			turn: ENEMY,
			start: (?options:BattleManagerStateOptions) ->
			{
				state = enemyEndState;

				for (turnable in this.turnables)
					turnable.onEnemyEndTurn();
			},
			update: (elapsed:Float) ->
			{
				if (bam.isQueueEmpty()) // wait for animations to finish before player's turn start
					playerStartState.start();
			}
		};

		this.winState = {
			name: WIN,
			turn: NONE,
			start: (?options:BattleManagerStateOptions) ->
			{
				this.state = winState;
				bss.showWinScreen();
			},
			update: (elapsed:Float) -> {}
		};

		this.loseState = {
			name: LOSE,
			turn: NONE,
			start: (?options:BattleManagerStateOptions) ->
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
