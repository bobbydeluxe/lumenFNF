package substates;

import backend.WeekData;

import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;

import states.StoryMenuState;
import mikolka.vslice.freeplay.FreeplayState;

class GameOverSubstate extends ScriptedSubState
{
	public var boyfriend:Character;
	var camFollow:FlxObject;

	var stagePostfix:String = '';

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var deathDelay:Float = 0;

	public static var instance:GameOverSubstate;
	public function new(?playStateBoyfriend:Character = null)
	{
		if(playStateBoyfriend != null && playStateBoyfriend.curCharacter == characterName) //Avoids spawning a second boyfriend cuz animate atlas is laggy
		{
			this.boyfriend = playStateBoyfriend;
		}
		super();
	}

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		deathDelay = 0;

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	var charX:Float = 0;
	var charY:Float = 0;

	var overlay:FlxSprite;
	var overlayConfirmOffsets:FlxPoint = FlxPoint.get();
	override function create()
	{
		preCreate();
		
		instance = this;

		Conductor.songPosition = 0;

		if (boyfriend == null) {
			boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
			boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
			boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
		}
		boyfriend.skipDance = true;
		add(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		add(camFollow);
		
		PlayState.instance?.stagesFunc((stage:BaseStage) -> stage.onGameOverStart());
		
		PlayState.instance?.setOnScripts('inGameOver', true);
		PlayState.instance?.callOnScripts('onGameOverStart', []);
		FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);

		super.create();
	}

	override function update(elapsed:Float)
	{
		preUpdate(elapsed);
		
		super.update(elapsed);
		
		PlayState.instance?.callOnScripts('onUpdate', [elapsed]);

		var justPlayedLoop:Bool = false;
		if (!boyfriend.isAnimationNull() && boyfriend.getAnimationName() == 'firstDeath' && boyfriend.isAnimationFinished()) {
			boyfriend.playAnim('deathLoop');
			if(overlay != null && overlay.animation.exists('deathLoop')) {
				overlay.visible = true;
				overlay.animation.play('deathLoop');
			}
			justPlayedLoop = true;
		}

		if(!isEnding)
		{
			if (controls.ACCEPT)
			{
				endBullshit();
			}
			else if (controls.BACK)
			{
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				FlxG.camera.visible = false;
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				
				PlayState.instance?.stagesFunc((stage:BaseStage) -> stage.onGameOverConfirm(false));
				
				var stopped:Bool = (callOnScripts('onGameOverConfirm', [false], true) == psychlua.LuaUtils.Function_Stop);
				stopped = (stopped || (PlayState.instance != null && PlayState.instance.callOnScripts('onGameOverConfirm', [false], true) == psychlua.LuaUtils.Function_Stop));
				
				if (!stopped) {
					Mods.loadTopMod();
					
					if (PlayState.isStoryMode)
					{
						PlayState.storyPlaylist = [];
						openSubState(new StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
					}
					else
					{
						openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker)));
					}
				}
			} else if (justPlayedLoop) {
				coolStartDeath();
			}
			
			if (FlxG.sound.music.playing)
				Conductor.songPosition = FlxG.sound.music.time;
		}
		
		PlayState.instance?.callOnScripts('onUpdatePost', [elapsed]);
		
		postUpdate(elapsed);
	}

	public var isEnding:Bool = false;
	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.music.play(true);
		FlxG.sound.music.volume = volume;
		
		PlayState.instance?.stagesFunc((stage:BaseStage) -> stage.onGameOverLoop());
		PlayState.instance?.callOnScripts('onGameOverLoop', []);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (boyfriend.hasAnimation('deathConfirm')) {
				boyfriend.playAnim('deathConfirm', true);
			} else if (boyfriend.hasAnimation('deathLoop')) {
				boyfriend.playAnim('deathLoop', true);
			}

			if(overlay != null && overlay.animation.exists('deathConfirm')) {
				overlay.visible = true;
				overlay.animation.play('deathConfirm');
				overlay.offset.set(overlayConfirmOffsets.x, overlayConfirmOffsets.y);
			}
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			
			new FlxTimer().start(.7, (_) -> {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, () -> MusicBeatState.resetState());
			});
			
			PlayState.instance?.stagesFunc((stage:BaseStage) -> stage.onGameOverConfirm(true));
			
			callOnScripts('onGameOverConfirm', [true]);
			PlayState.instance?.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
