package backend;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.GlobalScriptHandler;
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import psychlua.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

class ScriptedSubState extends MusicBeatSubstate {
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end
	#if HSCRIPT_ALLOWED public var hscriptArray:Array<HScript> = []; #end
	public static var stInstance:ScriptedSubState;
	
	var multiScript:Bool = true;
	var loadedScripts:Bool = false;
	
	public var scriptFolder:String = 'scripts';

	public function new() {
		super();
		stInstance = this;
	}
	
	public override function create():Void {
		super.create();
	}
	override function _preCreate():Void {
		#if SCRIPTS_ALLOWED startStateScripts(); #end
		
		GlobalScriptHandler.call('onCreateSubState', [this]);
	}
	override function _postCreate():Void {
		callOnScripts('onCreatePost');
		
		GlobalScriptHandler.call('onCreateSubStatePost', [this]);
	}
	
	var _shouldUpdate:Bool = true;
	public function preUpdate(elapsed:Float):Void {
		_shouldUpdate = (callOnScripts('onUpdate', [elapsed], true) != LuaUtils.Function_Stop);
	}
	public override function update(elapsed:Float):Void {
		if (_shouldUpdate)
			super.update(elapsed);
		_shouldUpdate = true;
	}
	public function postUpdate(elapsed:Float):Void {
		callOnScripts('onUpdatePost', [elapsed]);
	}
	
	public override function updatePresence():Void {
		if (callOnScripts('onUpdatePresence', [rpcDetails, rpcState], true) != LuaUtils.Function_Stop)
			super.updatePresence();
	}
	
	public override function draw():Void {
		if (callOnScripts('onDraw', true) == LuaUtils.Function_Stop) return;
		super.draw();
		callOnScripts('onDrawPost');
	}
	
	public override function openSubState(subState:flixel.FlxSubState):Void {
		var stopped:Bool = (callOnHScript('onOpenSubState', [subState], true) == LuaUtils.Function_Stop);
		stopped = (stopped || callOnLuas('onOpenSubState', [getStateName(subState)], true) == LuaUtils.Function_Stop);
		
		if (!stopped)
			super.openSubState(subState);
	}
	
	public override function close():Void {
		if (callOnScripts('onClose', true) != LuaUtils.Function_Stop && GlobalScriptHandler.call('onCloseSubState', [this]) != LuaUtils.Function_Stop)
			super.close();
	}
	
	public override function sectionHit(section:Int):Void {
		super.sectionHit(section);
		
		callOnScripts('onSectionHit', [section]);
	}
	public override function beatHit(beat:Int):Void {
		super.beatHit(beat);
		
		callOnScripts('onBeatHit', [beat]);
	}
	public override function stepHit(step:Int):Void {
		super.stepHit(step);
		
		callOnScripts('onStepHit', [step]);
	}
	
	override function updateSection():Void {
		super.updateSection();
		
		setOnLuas('curSection', curSection);
		setOnLuas('curDecSection', curDecSection);
	}
	override function updateBeat():Void {
		super.updateBeat();
		
		setOnLuas('curBeat', curBeat);
		setOnLuas('curDecBeat', curDecBeat);
	}
	override function updateStep():Void {
		super.updateStep();
		
		setOnLuas('curStep', curStep);
		setOnLuas('curDecStep', curDecStep);
	}
	
	public override function destroy():Void {
		#if SCRIPTS_ALLOWED destroyScripts(); #end
		super.destroy();
	}
	
	public static function getStateName(state:flixel.FlxSubState):String { // Used to load the appropriate substate script
		if (state is ScriptedSubState) {
			return cast(state, ScriptedSubState).customStateName();
		} else {
			var clsName:String = Type.getClassName(Type.getClass(state));
			return clsName.substr(clsName.lastIndexOf('.') + 1);
		}
	}
	public function customStateName():String { 
		var clsName:String = Type.getClassName(Type.getClass(this));
		return clsName.substr(clsName.lastIndexOf('.') + 1);
	}
	function getFolderName():String {
		return 'substates';
	}
	
	#if SCRIPTS_ALLOWED
	public function startStateScripts():Bool {
		loadedScripts = false;
		
		#if HSCRIPT_ALLOWED
		loadedScripts = startHScripts();
		#end
		#if LUA_ALLOWED
		if (multiScript || !loadedScripts)
			loadedScripts = (startLuas() || loadedScripts);
		#end
		
		return loadedScripts;
	}
	
	public function destroyScripts():Void {
		#if LUA_ALLOWED
		for (lua in luaArray) {
			lua.call('onDestroy');
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			if (script.exists('onDestroy'))
				script.call('onDestroy');
			script.destroy();
		}
		hscriptArray = null;
		#end
	}
	#end
	
	#if LUA_ALLOWED
	function startLuas():Bool {
		var loaded:Bool = false;
		
		if (multiScript) {
			for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), scriptFolder)) {
				var prefix:String = getFolderName();
				if (prefix.length > 0) prefix += '/';
				
				var path:String = '$folder/$prefix${customStateName()}.lua';
				if (FileSystem.exists(path))
					loaded = (initLuaScript(path) != null || loaded);
			}
		} else {
			var prefix:String = getFolderName();
			if (prefix.length > 0) prefix += '/';
			
			var file:String = 'scripts/$prefix${customStateName()}.lua';
			var path:String = Paths.modFolders(file);
			if (FileSystem.exists(path))
				loaded = (initLuaScript(path) != null);
		}
		
		return loaded;
	}
	public function startLuasNamed(luaFile:String) {
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			initLuaScript(luaToLoad);
			return true;
		}
		return false;
	}
	public function initLuaScript(file:String):FunkinLua {
		var lua:FunkinLua = FunkinLua.initFromFile(file, this);
		if (lua != null) luaArray.push(lua);
		
		return lua;
	}
	
	public function implementLua(lua:FunkinLua):Void {}
	#end
	
	#if HSCRIPT_ALLOWED
	function startHScripts():Bool {
		var loaded:Bool = false;
		
		if (multiScript) {
			for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), scriptFolder)) {
				var prefix:String = getFolderName();
				if (prefix.length > 0) prefix += '/';
				
				var path:String = '$folder/$prefix${customStateName()}.hx';
				if (FileSystem.exists(path))
					loaded = (initHScript(path) != null || loaded);
			}
		} else {
			var prefix:String = getFolderName();
			if (prefix.length > 0) prefix += '/';
			
			var file:String = '$scriptFolder/$prefix${customStateName()}.hx';
			var path:String = Paths.modFolders(file);
			if (FileSystem.exists(path))
				loaded = (initHScript(path) != null);
		}
		
		return loaded;
	}
	public function startHScriptsNamed(scriptFile:String) {
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad)) {
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}
	public function initHScript(file:String):HScript {
		var hs:HScript = HScript.initFromFile(file, this);
		if (hs != null) hscriptArray.push(hs);
		
		return hs;
	}
	#end
	
	public function callOnScripts(func:String, ?args:Array<Dynamic>, ignoreStops:Bool = false, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>):Dynamic {
		excludeValues ??= [];
		excludeValues.push(LuaUtils.Function_Continue);
		
		var result:Dynamic = callOnLuas(func, args, ignoreStops, exclusions, excludeValues);
		if (result == null || excludeValues.contains(result))
			result = callOnHScript(func, args, ignoreStops, exclusions, excludeValues);
		
		return result;
	}
	public function callOnScriptsExt(func:String, ?argsLua:Array<Dynamic>, ?argsHScript:Array<Dynamic>, ignoreStops:Bool = false, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>):Dynamic {
		excludeValues ??= [];
		excludeValues.push(LuaUtils.Function_Continue);
		
		var result:Dynamic = callOnLuas(func, argsLua, ignoreStops, exclusions, excludeValues);
		if (result == null || excludeValues.contains(result))
			result = callOnHScript(func, argsHScript, ignoreStops, exclusions, excludeValues);
		
		return result;
	}
	public function callOnLuas(func:String, ?args:Array<Dynamic>, ignoreStops:Bool = false, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if (luaArray == null) return returnVal;
		
		exclusions ??= [];
		excludeValues ??= [];
		excludeValues.push(LuaUtils.Function_Continue);

		var arr:Array<FunkinLua> = [];
		for (script in luaArray) 	{
			if (script.closed) {
				arr.push(script);
				continue;
			}

			if (exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(func, args);
			if ((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops) {
				returnVal = myValue;
				break;
			}

			if (myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if (script.closed) arr.push(script);
		}

		if (arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}
	public function callOnHScript(funcToCall:String, ?args:Array<Dynamic>, ?ignoreStops:Bool = false, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if (hscriptArray == null) return returnVal;
		
		exclusions ??= [];
		excludeValues ??= [];
		excludeValues.push(LuaUtils.Function_Continue);
		
		for (script in hscriptArray) {
			if (script.closed || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if (callValue != null) {
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops) {
					returnVal = myValue;
					break;
				}

				if (myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end

		return returnVal;
	}
	
	public function setOnScripts(variable:String, args:Dynamic, ?exclusions:Array<String>):Void {
		setOnLuas(variable, args, exclusions);
		setOnHScript(variable, args, exclusions);
	}
	public function setOnLuas(variable:String, args:Dynamic, ?exclusions:Array<String>):Void {
		#if LUA_ALLOWED
		if (luaArray == null) return;
		
		exclusions ??= [];
		for (script in luaArray) {
			if (script.closed || exclusions.contains(script.scriptName))
				continue;

			script.set(variable, args);
		}
		#end
	}
	public function setOnHScript(variable:String, args:Dynamic, ?exclusions:Array<String>):Void {
		#if HSCRIPT_ALLOWED
		if (hscriptArray == null) return;
		
		exclusions ??= [];
		for (script in hscriptArray) {
			if (script.closed || exclusions.contains(script.origin))
				continue;

			script.set(variable, args);
		}
		#end
	}
}