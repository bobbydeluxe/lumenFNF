package psychlua;

import openfl.utils.Assets;

#if (LUA_ALLOWED && flxanimate)
class FlxAnimateFunctions {
	public static function implement() {
		FunkinLua.registerFunction("makeFlxAnimateSprite", function(tag:String, ?x:Float = 0, ?y:Float = 0, ?loadFolder:String = null) {
			tag = tag.replace('.', '');
			var lastSprite = MusicBeatState.getVariables().get(tag);
			if(lastSprite != null) {
				lastSprite.kill();
				PlayState.instance.remove(lastSprite);
				lastSprite.destroy();
			}

			var mySprite:ModchartAnimateSprite = new ModchartAnimateSprite(x, y);
			if(loadFolder != null) Paths.loadAnimateAtlas(mySprite, loadFolder);
			MusicBeatState.getVariables().set(tag, mySprite);
			mySprite.active = true;
		});

		FunkinLua.registerFunction("loadAnimateAtlas", function(tag:String, folderOrImg:String, ?spriteJson:String = null, ?animationJson:String = null) {
			var spr:FlxAnimate = LuaUtils.getObjectDirectly(tag);
			if (spr != null) Paths.loadAnimateAtlas(spr, folderOrImg, spriteJson, animationJson);
		});
		
		FunkinLua.registerFunction("addAnimationBySymbol", function(tag:String, name:String, symbol:String, ?framerate:Float = 24, ?loop:Bool = false, ?matX:Float = 0, ?matY:Float = 0) {
			var obj:FlxAnimate = LuaUtils.getObjectDirectly(tag);
			if (obj == null) return false;

			obj.anim.addBySymbol(name, symbol, framerate, loop, matX, matY);
			if(obj.anim.curSymbol == null) {
				var obj2:ModchartAnimateSprite = cast (obj, ModchartAnimateSprite);
				if(obj2 != null) obj2.playAnim(name, true); //is ModchartAnimateSprite
				else obj.anim.play(name, true);
			}
			return true;
		});

		FunkinLua.registerFunction("addAnimationBySymbolIndices", function(tag:String, name:String, symbol:String, ?indices:Any = null, ?framerate:Float = 24, ?loop:Bool = false, ?matX:Float = 0, ?matY:Float = 0) {
			var obj:FlxAnimate = LuaUtils.getObjectDirectly(tag);
			if (obj == null) return false;

			if(indices == null)
				indices = [0];
			else if(Std.isOfType(indices, String))
			{
				var strIndices:Array<String> = cast (indices, String).trim().split(',');
				var myIndices:Array<Int> = [];
				for (i in 0...strIndices.length) {
					myIndices.push(Std.parseInt(strIndices[i]));
				}
				indices = myIndices;
			}

			obj.anim.addBySymbolIndices(name, symbol, indices, framerate, loop, matX, matY);
			if(obj.anim.curSymbol == null)
			{
				var obj2:ModchartAnimateSprite = cast (obj, ModchartAnimateSprite);
				if(obj2 != null) obj2.playAnim(name, true); //is ModchartAnimateSprite
				else obj.anim.play(name, true);
			}
			return true;
		});
	}
}
#end