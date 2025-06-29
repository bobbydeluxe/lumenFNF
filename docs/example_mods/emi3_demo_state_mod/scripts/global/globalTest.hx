import Type;
import Reflect;
import options.OptionsState;
import psychlua.GlobalScriptHandler;

function onCreate() {
	trace('hi from ' + this.filePath + '!');
}

function onCreateStatePost(state:FlxState, cls:Class<Dynamic>):Dynamic {
	trace('state created ' + cls);
}

function onRegisterLuaAPI():Void {
	FunkinLua.registerFunction('funnyFunction', function() {
		debugPrint('this function is funny.', 0xffff00);
	});
}

function onSwitchState(state:FlxState, cls:Class<Dynamic>):Dynamic {
	trace('switching state to ' + cls);
	if (!FlxG.keys.pressed.SHIFT && cls == OptionsState) {
		trace('sike!! REDIRECT TO CUSTOM STATE (press shift to ignore)');
		
		MusicBeatState.switchState(new CustomState('CustomStateTest'));
		return Function_Stop;
	}
}

function onDestroy():Void {
	trace('bye!!');
}

function stateIs(state:Dynamic, cls:Class):Bool {
	//
}