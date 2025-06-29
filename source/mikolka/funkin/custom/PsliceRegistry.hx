package mikolka.funkin.custom;

import mikolka.compatibility.FunkinPath;
import haxe.Json;

class PsliceRegistry {
    final regPath:String;

    public function new(registryName:String) {
        regPath = 'registry/$registryName';
    }

    function readJson(id:String):Dynamic {
        var char_path = FunkinPath.getPath('$regPath/$id.json');
        if(!NativeFileSystem.exists(char_path)) return null;
        var text = NativeFileSystem.getContent(char_path);

        return Json.parse(text);// new PlayerData();
    }

    /*
     * "why tf is there a baseOnly argument" you might ask
     * its so charselect can scan only native characters for native directories
     * thanks mikolka for telling me where this fucking code was
     * - bobbyDX
     */
    function listJsons(baseOnly:Bool = false):Array<String> {
        if (baseOnly) {
            var char_path = FunkinPath.getPath(regPath, true); // true = native/base
            var baseCharFiles = NativeFileSystem.readDirectory(char_path);
            return baseCharFiles.filter(s -> s.endsWith(".json")).map(s -> s.substr(0, s.length - 5));
        } else {
            var char_path = FunkinPath.getPath(regPath);
            var basedCharFiles = NativeFileSystem.readDirectory(char_path);
            if(char_path == 'mods/$regPath'){
            var nativeChars = NativeFileSystem.readDirectory(FunkinPath.getPath(regPath,true));
            basedCharFiles = basedCharFiles.concat(nativeChars);
            }
            return basedCharFiles.filter(s -> s.endsWith(".json")).map(s -> s.substr(0,s.length-5));
        }
    }
}