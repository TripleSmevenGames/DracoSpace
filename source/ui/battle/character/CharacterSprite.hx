package ui.battle.character;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import managers.BattleAnimationManager;
import managers.BattleManager;
import managers.BattleSoundManager as BSM;
import managers.GameController;
import models.CharacterInfo;
import models.ai.EnemyIntentMaker.Intent;
import models.skills.Skill;
import models.skills.SkillFactory;
import ui.TooltipLayer.Tooltip;
import ui.battle.IBattleTriggerable;
import ui.battle.status.Status;
import ui.battle.win.SkillCard;
import utils.GameUtils;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

using utils.GameUtils;
using utils.ViewUtils;

/** Represents a character's sprite during battle. Centered on the body sprite **/
class CharacterSprite extends FlxSpriteGroup implements ITurnTriggerable
{
	public var info:CharacterInfo;
	public var maxHp:Int;
	public var currHp(default, set):Int;
	public var currBlock(default, set):Int;
	public var skillSprites:Array<SkillSprite> = new Array<SkillSprite>();
	public var skillsPlayedThisTurn:Int = 0;
	public var dead(default, set):Bool = false;

	var mouseOverCallbacks:Array<FlxSprite->Void> = [];
	var mouseOutCallbacks:Array<FlxSprite->Void> = [];
	var leftClickCallbacks:Array<FlxSprite->Void> = [];
	var rightClickCallbacks:Array<FlxSprite->Void> = [];

	/*** the "body" of the character. **/
	public var sprite:FlxSprite;

	// an arrow pointing to the body, which will appear when you are targeting a skill.
	public var targetArrow:FlxSprite;

	// the character's hp and block displays.
	var hpBarSprite:CharacterHpBar;

	var statusDisplay:CharacterStatusDisplay;

	// enemy only.
	var enemyIntentSprites:EnemyIntentSprites;

	// the BM will set this btn's click handler to cancel a skill
	public var cancelSkillBtn:FlxSprite;

	// reference to the global managers.
	var bm:BattleManager;
	var bam:BattleAnimationManager;

	/** The battle context that this character is in. Should only be set by the BM. **/
	public var context:BattleContext;

	// internal timer used for some animations.
	var timer:FlxTimer;

	/** Array of sounds to play with this character takes damage. Should be assetPaths from the BattleSoundManager. **/
	var hitSoundArray:Array<String>;

	// target arrow X distance from char sprite.
	public static inline final TARGET_ARROW_DISTANCE = 16;

	// since we are using an FlxBar for the hp bar, the bar should automatically update
	// we don' t need to explicitly call update on it
	public function set_currHp(val:Int)
	{
		if (val > maxHp)
		{
			val = maxHp;
		}
		else if (val <= 0)
		{
			val = 0;
			if (!dead)
			{
				// test: this order should work.
				dead = true;
				queueDeadAnimation();
				this.statusDisplay.onDead(this.context);
				this.statusDisplay.removeAllStatuses();
			}
		}
		this.info.currHp = val; // set the hp on the char info too.
		return currHp = val;
	}

	// we'll have to explicitly update the block indicator.
	public function set_currBlock(val:Int)
	{
		if (val < 0)
			val = 0;

		if (hpBarSprite != null)
			hpBarSprite.updateBlockIndicator(val);

		return currBlock = val;
	}

	function set_dead(val:Bool)
	{
		dead = val;
		if (val)
		{
			disableAllSkills();
		}
		return dead;
	}

	function playHitSound()
	{
		var soundToPlay = this.hitSoundArray.getRandomChoice();
		GameController.battleSoundManager.playSound(soundToPlay);
	}

	/** Add that many stacks of the status to this char. **/
	public function addStatus(type:StatusType, stacks:Int = 1)
	{
		statusDisplay.addStatusByType(type, stacks);
		spawnDamageNumber('+${type.getName()}', ViewUtils.getColorForStatus(type), false);
	}

	/** Completely remove the status from the char. Returns the stacks removed.**/
	public function removeStatus(type:StatusType)
	{
		return statusDisplay.removeStatusByType(type);
	}

	public function removeStacksOnStatus(type:StatusType, stacks:Int = 1)
	{
		statusDisplay.removeStacks(type, stacks);
	}

	/** Returns the number of stacks of the status, or 0 if they dont have the status. **/
	public function getStatus(type:StatusType)
	{
		if (statusDisplay != null)
			return statusDisplay.getStatus(type);
		return 0;
	}

	/** Call this function for the character to take damage. **/
	public function takeDamage(val:Int, dealer:CharacterSprite, context:BattleContext, blockable = true)
	{
		if (dead)
		{
			return;
			trace('a dead char took damage. ${this.info.name}');
		}

		if (getStatus(DODGE) > 0)
		{
			removeStacksOnStatus(DODGE, 1);
			GameController.battleSoundManager.playSound(BSM.miss);
			spawnDamageNumber('MISS');
			return;
		}

		// reduce damage for each stack of sturdy.
		var sturdyVal = getStatus(STURDY);
		val -= sturdyVal;

		if (val == 0)
		{
			GameController.battleSoundManager.playSound(BSM.miss);
			spawnDamageNumber('MISS');
			return;
		}

		// call onTakeDamage before damage is actually taken.
		// That way if the character dies from this damage, the status' onTakeDamage will still fire.
		this.onTakeDamage(val, dealer, context);

		// if the damage is blockable (which is true by default)
		// calculate the damage to hp and block, and play the right sounds.
		if (blockable)
		{
			if (val > currBlock)
			{
				playHitSound();
				playHurtAnimation();
				currHp -= (val - currBlock);
			}
			else
			{
				GameController.battleSoundManager.playSound(BSM.blocked);
			}
			currBlock -= val;
		}
		// if its not blockable (like some self damage), just subtract from the hp.
		else
		{
			playHitSound();
			playHurtAnimation();
			currHp -= val;
		}
		spawnDamageNumber(Std.string(val));
	}

	/** Call this when one char deals damage to other char.
	**/
	public function dealDamageTo(val:Int, target:CharacterSprite, context:BattleContext)
	{
		val += this.statusDisplay.getStatus(ATTACK);
		val -= this.statusDisplay.getStatus(ATTACKDOWN);
		var modifiers:Float = 1;
		if (getStatus(WEAK) > 0)
			modifiers *= .75;

		if (target.getStatus(WOUNDED) > 0)
			modifiers *= 1.25;

		val = Std.int(val * modifiers);

		onDealDamage(val, target, context);
		target.takeDamage(val, this, context);
	}

	/** Call this when a character is paying hp to activate a skill. Still triggers onTakeDamage. **/
	public function payHealth(val:Int, context:BattleContext)
	{
		this.takeDamage(val, this, context, false);
	}

	public function healHp(val:Int)
	{
		if (dead)
		{
			return;
			trace('tried to heal a dead char: ${this.info.name}');
		}

		currHp += val;
		spawnDamageNumber('+${Std.string(val)}', FlxColor.GREEN, false);
	}

	function singleFlash()
	{
		sprite.alpha = sprite.alpha == 1 ? .5 : 1;
	}

	function playHurtAnimation()
	{
		if (!timer.finished)
			return;

		var time = .1;
		var loops = 6;
		var onComplete = (_) -> singleFlash();

		timer.start(time, onComplete, loops);
	}

	public function playIdle()
	{
		this.sprite.animation.play('idle');
	}

	public function isPlayingHurtAnimation()
	{
		return !timer.finished;
	}

	/** Add the "fading out" animation to the bam. **/
	function queueDeadAnimation()
	{
		var onComplete = (_) ->
		{
			this.kill();
		}
		var tween = FlxTween.tween(sprite, {alpha: 0}, 1, {onComplete: onComplete});
		bam.addTweens([tween]);
	}

	function spawnDamageNumber(val:String, color:FlxColor = FlxColor.WHITE, usePhysics:Bool = true)
	{
		if (sprite == null)
			return;

		var spawnX = sprite.x + sprite.width / 2;
		var spawnY = sprite.y;

		GameController.battleDamageNumbers.spawnDamageNumber(spawnX, spawnY, val, color, usePhysics);
	}

	/** Just places the intent sprites so they float above the body properly.
	 * Only Enemies should have intent sprites
	**/
	function rerenderEnemyIntentSprites()
	{
		if (enemyIntentSprites != null)
		{
			var xPos = sprite.x + sprite.width / 2;
			var yPos = sprite.y - enemyIntentSprites.height / 2;
			enemyIntentSprites.setPosition(xPos, yPos);
		}
	}

	public function addIntent(intent:Intent)
	{
		if (enemyIntentSprites != null)
		{
			enemyIntentSprites.addIntent(intent);
			rerenderEnemyIntentSprites();
		}
	}

	public function resetIntents()
	{
		if (enemyIntentSprites != null)
		{
			enemyIntentSprites.resetIntents();
			rerenderEnemyIntentSprites();
		}
	}

	function disableAllSkills()
	{
		for (skillSprite in skillSprites)
		{
			skillSprite.checkDisabled();
		}
	}

	function refreshAllSkills()
	{
		for (skillSprite in skillSprites)
		{
			skillSprite.onNewRound();
		}
	}

	/** Check to see if any skills should be disabled. This happens when this char gets stunned. **/
	public function checkDisabled()
	{
		for (skillSprite in skillSprites)
			skillSprite.checkDisabled();
	}

	public function onPlayerStartTurn(context:BattleContext)
	{
		if (this.info.type == PLAYER)
		{
			currBlock = 0;
			statusDisplay.onPlayerStartTurn(context);
		}

		refreshAllSkills(); // refresh both the players' and the enemies' skills.
	}

	public function onPlayerEndTurn(context:BattleContext)
	{
		if (this.info.type == PLAYER)
		{
			statusDisplay.onPlayerEndTurn(context);
			skillsPlayedThisTurn = 0;
		}
	}

	public function onEnemyStartTurn(context:BattleContext)
	{
		if (this.info.type == ENEMY)
		{
			currBlock = 0;
			statusDisplay.onEnemyStartTurn(context);
			resetIntents();
		}
	}

	public function onEnemyEndTurn(context:BattleContext)
	{
		if (this.info.type == ENEMY)
		{
			statusDisplay.onEnemyEndTurn(context);
			skillsPlayedThisTurn = 0;
		}
	}

	/** Called BEFORE the target actually takes the damage. **/
	function onDealDamage(damage:Int, target:CharacterSprite, context:BattleContext)
	{
		statusDisplay.onDealDamage(damage, target, context);
	}

	/** This is called BEFORE the char takes the damage. **/
	function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		statusDisplay.onTakeDamage(damage, dealer, context);
		if (damage > 0 && damage < 10)
			GameUtils.smallCameraShake();
		else if (damage < 20)
			GameUtils.mediumCameraShake();
		else
			GameUtils.bigCameraShake();
	}

	function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		skillsPlayedThisTurn += 1;
		statusDisplay.onPlaySkill(skillSprite, context);
	}

	public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		statusDisplay.onAnyPlaySkill(skillSprite, context);
	}

	/** The skill is counted as a played skill before it's play() is called.**/
	public function playSkill(skillSprite:SkillSprite, targets:Array<CharacterSprite>, context:BattleContext)
	{
		onPlaySkill(skillSprite, context);
		skillSprite.play(targets, context);
	}

	/** adds a left click callback, which will fire when clicked if the skill is not disabled. **/
	public function setOnClick(onClick:CharacterSprite->Void)
	{
		leftClickCallbacks.push((sprite:FlxSprite) -> onClick(this));
	}

	/** adds a right click callback, which will fire when right clicked if the skill is not disabled. **/
	public function setOnRightClick(onClick:CharacterSprite->Void)
	{
		rightClickCallbacks.push((sprite:FlxSprite) -> onClick(this));
	}

	public function setOnHover(over:CharacterSprite->Void, out:CharacterSprite->Void)
	{
		mouseOverCallbacks.push((sprite:FlxSprite) -> over(this));
		mouseOutCallbacks.push((sprite:FlxSprite) -> out(this));
	}

	public function setOnClickCancelSkill(onClick:Void->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(cancelSkillBtn, (_) -> onClick());
	}

	public static function sampleRyder()
	{
		return new CharacterSprite(CharacterInfo.sampleRyder());
	}

	public static function loadSpriteSheetInfo(ssi:SpriteSheetInfo)
	{
		var frameRate = 10;
		var sprite = new FlxSprite(0, 0);
		sprite.loadGraphic(ssi.spritePath, true, ssi.width, ssi.height);
		sprite.animation.add('idle', ssi.idleFrames, frameRate, true);
		sprite.scale3x();
		return sprite;
	}

	/** Setup this character's sprite. It is the reference for the rest of the things, so probably should call this first. **/
	function setupSprite(spriteSheetInfo:SpriteSheetInfo)
	{
		this.sprite = loadSpriteSheetInfo(spriteSheetInfo);
		sprite.scale3x();
		ViewUtils.centerSprite(sprite, 0, 0);
		this.add(sprite);

		// add the targeting arrow. Render right side for players, left side for enemies,
		// assumes sprite is at 0, 0.
		var targetArrowXPos = TARGET_ARROW_DISTANCE + sprite.width / 2;
		if (this.info.type == PLAYER)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.YellowArrow3L__png);
			ViewUtils.centerSprite(targetArrow, targetArrowXPos, 0);
		}
		else if (this.info.type == ENEMY)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.YellowArrow3R__png);
			ViewUtils.centerSprite(targetArrow, -targetArrowXPos, 0);
		}
		targetArrow.scale3x();
		add(targetArrow);
		targetArrow.visible = false;

		// if this is an enemy, render the intent container (should be empty rn).
		if (this.info.type == ENEMY)
		{
			this.enemyIntentSprites = new EnemyIntentSprites();
			add(enemyIntentSprites);
		}

		// add the hover affect, which just shows the character's name on hover;
		GameController.battleTooltipLayer.createTooltipForChar(this);
	}

	/** Make skills to this character. They will be rendered by the DeckSprite */
	function setupSkills(skills:Array<Skill>)
	{
		var skills = this.info.skills;
		for (i in 0...skills.length)
		{
			var skill = skills[i];
			var skillSprite = new SkillSprite(skill, this);
			skillSprites.push(skillSprite);
		}
	}

	/** Setup this character's HPbar and block indicator. Call this after setupSprite. **/
	function setupHpBar()
	{
		hpBarSprite = new CharacterHpBar(this);
		hpBarSprite.setPosition(0, this.sprite.height / 2 + 8);
		add(hpBarSprite);
	}

	/** Setup the spot under the HP bar where the char's statuses will show up. **/
	function setupStatusDisplay()
	{
		statusDisplay = new CharacterStatusDisplay(this);
		statusDisplay.setPosition(0, hpBarSprite.y + 28);
		add(statusDisplay);
	}

	function setupCancelSkillButton()
	{
		cancelSkillBtn = new FlxSprite(0, 0, AssetPaths.cancelTargeting__png);
		cancelSkillBtn.scale3x();
		cancelSkillBtn.centerSprite(-sprite.width);
		this.add(cancelSkillBtn);
		// killing the cancel button here causes uber weird behavior, so don't do it!!

		FlxMouseEventManager.add(cancelSkillBtn);
		var tooltip = Tooltip.genericTooltip('Cancel', null, {});
		GameController.battleTooltipLayer.registerTooltip(tooltip, cancelSkillBtn);
	}

	/** Call this after status display is setup**/
	function setupInitialStatuses()
	{
		for (status in this.info.initialStatuses)
		{
			statusDisplay.addStatusByType(status);
		}
	}

	public function new(info:CharacterInfo)
	{
		super(0, 0);
		this.info = info;
		this.bm = GameController.battleManager;
		this.bam = GameController.battleAnimationManager;

		maxHp = info.maxHp;
		currHp = info.currHp;
		currBlock = 0;
		// if character dies, this breaks
		setupSprite(info.spriteSheetInfo);

		setupHpBar();

		setupStatusDisplay();

		setupSkills(info.skills);

		setupInitialStatuses();

		if (info.type == PLAYER)
			setupCancelSkillButton();

		this.timer = new FlxTimer();
		timer.cancel();

		this.hitSoundArray = BSM.getHitSoundArrayForType(info.soundType);

		// setup the mouse events
		// setup the mouse events
		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		// In order for right click to work, we need to set the mouseButtons arg
		var mouseOver = (sprite:FlxSprite) ->
		{
			for (callback in mouseOverCallbacks)
				callback(sprite);
		};

		var mouseOut = (sprite:FlxSprite) ->
		{
			for (callback in mouseOutCallbacks)
				callback(sprite);
		};

		var mouseClick = (sprite:FlxSprite) ->
		{
			// left click activated this click
			if (FlxG.mouse.justReleased)
			{
				for (callback in leftClickCallbacks)
					callback(sprite);
			}
			// right click activated this click
			else if (FlxG.mouse.justReleasedRight)
			{
				for (callback in rightClickCallbacks)
					callback(sprite);
			}
		};

		// note, for right clicking to work, you MUST add the click handler through add() like this, with the MouseButtons arg.
		// You cannot do .setMouseClickCallback() for right clicks.
		FlxMouseEventManager.add(sprite, null, mouseClick, mouseOver, mouseOut, false, true, false, [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT]);
		FlxMouseEventManager.add(targetArrow, null, mouseClick, mouseOver, mouseOut, false, true, false, [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT]);
	}
}
