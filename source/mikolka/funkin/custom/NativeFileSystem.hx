package mikolka.funkin.custom;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;

class NativeFileSystem {
    public static inline function getContent(path:String) {
        #if sys
		return (FileSystem.exists(path)) ? File.getContent(path) : null;
		#else
		return (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		#end
    }
    public static inline function exists(path:String) {
        #if sys
		return FileSystem.exists(path);
		#else
		return OpenFlAssets.exists(path, TEXT);
		#end
    }
    public static function readDirectory(directory:String):Array<String>
        {
            #if MODS_ALLOWED
            return FileSystem.readDirectory(directory);
            #else
            var dirs:Array<String> = [];
            for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
            {
                @:privateAccess
                for(library in lime.utils.Assets.libraries.keys())
                {
                    if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
                        dirs.push('$library:$dir');
                    else if(Assets.exists(dir) && !dirs.contains(dir))
                        dirs.push(dir);
                }
            }
            return dirs;
            #end
        }
    
    public static function getBitmap(path:String):Null<BitmapData>
	{
		#if nativesys_profile var timeStart = Sys.time(); #end
		var isModded = path.startsWith("mods");

		#if OPENFL_LOOKUP
		if (#if NATIVE_LOOKUP !isModded && #end OpenFlAssets.exists(path, IMAGE))
		{
			var result = OpenFlAssets.getBitmapData(path);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting native bitmap ${path} took: $timeEnd');
			#end
			return result;
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return null;
		#end
		var sys_path = getPathLike(path);
		if (sys_path != null)
		{
			var result = BitmapData.fromFile(sys_path);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting system bitmap ${path} took: $timeEnd');
			#end
			return result;
		}
		#end

		return null;
	}
}