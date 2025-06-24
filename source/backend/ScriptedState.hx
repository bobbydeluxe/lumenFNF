package backend;

import psychlua.GlobalScriptHandler;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

class ScriptedState extends ScriptedSubState {
	public static var camOther:FlxCamera = null;
	
	public static function debugPrint(text:String, ?color:FlxColor, ?size:Int):Void {
		Log.print(text, (color == null ? NONE : CUSTOM(color)), size);
	}
	
	public override function create():Void {
		#if MODS_ALLOWED Mods.updatedOnState = false; #end
		
		super.create();
		
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;
		
		MusicBeatState.timePassedOnState = 0;
	}
	public override function preCreate():Void {
		GlobalScriptHandler.refreshScripts();
		
		if (camOther == null) {
			camOther = new FlxCamera();
			camOther.bgColor.alpha = 0;
			FlxG.cameras.add(camOther, false);
		}
		
		if (!_psychCameraInitialized)
			initPsychCamera();
		
		super.preCreate();
	}
	override function _preCreate():Void {
		#if SCRIPTS_ALLOWED startStateScripts(); #end
		
		GlobalScriptHandler.call('onCreateState', [this, Type.getClass(this)]);
	}
	override function _postCreate():Void {
		callOnScripts('onCreatePost');
		
		GlobalScriptHandler.call('onCreateStatePost', [this, Type.getClass(this)]);
	}
	#if SCRIPTS_ALLOWED
	public override function startStateScripts():Bool {
		var loaded:Bool = false;
		
		#if HSCRIPT_ALLOWED
		loaded = startHScripts();
		#end
		#if LUA_ALLOWED
		FunkinLua.registerFunctions();
		GlobalScriptHandler.call('onRegisterLuaAPI');
		callOnHScript('onRegisterLuaAPI');
		loaded = (startLuas() || loaded);
		#end
		
		return loaded;
	}
	#end
	
	public function initPsychCamera():PsychCamera {
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		return camera;
	}
	
	override function getFolderName():String {
		return 'states';
	}
}