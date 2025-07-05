package psychlua;

import flixel.FlxObject;
import substates.StickerSubState;
import mikolka.compatibility.ModsHelper;

class CustomSubstate extends ScriptedSubState implements PsychUIEventHandler.PsychUIEvent {
	public static var name:String = 'unnamed';
	public static var instance:ScriptedSubState;
	
	public var stateName:String;
	public var parentState:ScriptedSubState = null;
	
	#if LUA_ALLOWED
	public static function implement() {
		FunkinLua.registerFunction("openCustomSubstate", openCustomSubstate);
		FunkinLua.registerFunction("closeCustomSubstate", closeCustomSubstate);
		FunkinLua.registerFunction("insertToCustomSubstate", insertToCustomSubstate);
	}
	#end
	
	public static function openCustomSubstate(name:String, pauseGame:Bool = false) {
		if (pauseGame) {
			FlxG.camera.followLerp = 0;
			FlxG.state.persistentDraw = true;
			FlxG.state.persistentUpdate = false;
			
			if (PlayState.instance != null) {
				PlayState.instance.paused = true;
				PlayState.instance.vocals?.pause();
			}
			
			if (FlxG.sound.music != null)
				FlxG.sound.music.pause();
		}
		
		FlxG.state.openSubState(new CustomSubstate(name));
	}
	public static function closeCustomSubstate() {
		if (instance != null) {
			PlayState.instance.closeSubState();
			return true;
		}
		return false;
	}
	public static function insertToCustomSubstate(tag:String, ?pos:Int = -1) {
		if (instance != null) {
			var variableMap:Map<String, Dynamic> = MusicBeatState.getVariables();
			var tagObject:FlxObject = cast variableMap.get(tag);
			
			if (tagObject != null) {
				if (pos < 0) instance.add(tagObject);
				else instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}
	
	public override function create() {
		CustomSubstate.name = stateName;
		CustomSubstate.instance = this;

		if (stickerSubState != null)
			{
			  //this.persistentUpdate = true;
			  //this.persistentDraw = true;
		
			  openSubState(stickerSubState);
			  ModsHelper.clearStoredWithoutStickers();
			  stickerSubState.degenStickers();
			  //FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		
		if (Std.isOfType(_parentState, ScriptedSubState)) {
			parentState = cast _parentState;
		} else if (Std.isOfType(FlxG.state, ScriptedSubState)) {
			parentState = cast FlxG.state;
		}
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		parentState?.setOnHScript('customSubstate', this);
		parentState?.setOnScripts('customSubstateName', stateName);
		parentState?.callOnScripts('onCustomSubstateCreate', [stateName]);
		preCreate();
		super.create();
		parentState?.callOnScripts('onCustomSubstateCreatePost', [stateName]);
	}
	override function _preCreate():Void {
		var loaded:Bool = #if SCRIPTS_ALLOWED startStateScripts() #else false #end;
		
		if (!loaded) { // check if the custom substate functions exist within any script (assume it shouldnt error if that is the case)
			var funcNames:Array<String> = ['onCustomSubstateCreate', 'onCustomSubstateCreatePost', 'onCustomSubstateUpdate', 'onCustomSubstateUpdatePost', 'onCustomSubstateDestroy'];
			
			if (_parentState is ScriptedState) {
				var scriptedState:ScriptedState = cast _parentState;
				
				#if LUA_ALLOWED
				for (lua in scriptedState.luaArray) {
					for (funcName in funcNames)
						loaded = (loaded || lua.exists(funcName));
				}
				#end
				#if HSCRIPT_ALLOWED
				for (hscript in scriptedState.hscriptArray) {
					for (funcName in funcNames)
						loaded = (loaded || hscript.exists(funcName));
				}
				#end
			}
		}
		
		if (!loaded) {
			var e:String = #if SCRIPTS_ALLOWED 'Custom sub-state code was not found / had errors, for "$stateName"' #else 'State scripts are unsupported in this build' #end;
			ScriptedState.debugPrint(e, FlxColor.YELLOW);
			close();
		}
	}
	
	var stickerSubState:StickerSubState;
	public function new(name:String, ?stickers:StickerSubState = null) {
		super();
		stateName = name;
		multiScript = false;

		if (stickers != null)
		{
			stickerSubState = stickers;
		}
	}
	
	public override function update(elapsed:Float) {
		preUpdate(elapsed);
		super.update(elapsed);
		postUpdate(elapsed);
	}
	public override function preUpdate(elapsed:Float) {
		parentState?.callOnScripts('onCustomSubstateUpdate', [stateName, elapsed]);
		super.preUpdate(elapsed);
	}
	public override function postUpdate(elapsed:Float) {
		parentState?.callOnScripts('onCustomSubstateUpdatePost', [stateName, elapsed]);
		super.postUpdate(elapsed);
	}
	
	public override function customStateName():String {
		return stateName;
	}
	
	public override function destroy() {
		parentState?.callOnScripts('onCustomSubstateDestroy', [stateName]);
		parentState?.setOnScripts('customSubstateName', null);
		parentState?.setOnHScript('customSubstate', null);
		instance = null;
		name = 'unnamed';
		
		super.destroy();
	}

	public function UIEvent(id:String, sender:Dynamic) {
		callOnScripts('onUIEvent', [id, sender]);
	}
}