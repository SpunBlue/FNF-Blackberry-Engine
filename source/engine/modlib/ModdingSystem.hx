package engine.modlib;
#if CAN_MOD
import openfl.utils.AssetCache;
import engine.SongDefs.SongListJson;
import haxe.io.Path;
import lime.system.System;
import sys.FileSystem;
import openfl.media.Sound;
import sys.io.File;
import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import engine.modlib.ModdingSystem as Msys;
import flixel.system.FlxAssets.FlxGraphicAsset;

class ModdingSystem {
    public static var validMods:Map<String, ModData> = new Map();
    public static var curMod:ModData = null;

    /**
     * Updated in the `loadMods` function
     */
    public var amt2Search:Int = 0;

    /**
     * Updated in the `loadMods` function
     */
    public var curProgress:Int = 0;

    /*public function loadMods(){
        var rootDir = ModdingSystem.getRootPath();

        var mods:Array<String> = FileSystem.readDirectory(rootDir);

        for (mod in mods){
            var jsonPath:String = '$rootDir/$mod/mod.json';

            if (FileSystem.exists(jsonPath)){
                var modJson:ModJson = Json.parse(File.getContent(jsonPath));

                var songList:SongListJson = null;
                var songListPath:String = '${ModdingSystem.getModPathFromID(mod)}/assets/data/Songlist.json';

                if (FileSystem.exists(songListPath))
                    songList = Json.parse(File.getContent(songListPath));

                var data:ModData = {
                    id: mod,
                    mod: modJson,
                    songList: songList
                };

                ModdingSystem.validMods.set(mod, data);
            }
            else
                amt2Search -= 1;
        }
    }*/

    /**
     * Set the current Mod. WILL CLEAR MOD ASSET CACHE!!!
     * @param modID Mod ID
     */
    public static function setMod(modID:String){
        if (modID == "")
            modID = null;

        curMod = validMods.get(modID);
        ModAssets.mod_assets.clear();
    }

    /**
     * Returns the root path to the mod folder.
     * DOES NOT RETURN THE ROOT FOLDER OF THE CURRENTLY SELECTED MOD.
     */
    public static function getRootPath(){
        #if desktop
        return Path.normalize('${System.applicationDirectory}/mods/');
        #elseif android
        return Path.normalize('${System.documentsDirectory}/FNF-Blackberry-Engine/mods/');
        #end
    }

    public static function getModPath(){
        return Path.normalize('${getRootPath()}/${curMod.id}/');
    }

    public static function getModPathFromID(id:String){
        return Path.normalize('${getRootPath()}/$id/');
    }
}

class ModAssets {
    public static var mod_assets:AssetCache = new AssetCache();

    /**
     * Searches in the root folder of the currently loaded mod.
     * @param path Example: `assets/images/graphic.png`
     * @param detailedPath If enabled, it will use the raw path instead of automatically fixing and finding the path.
     * @return `BitmapData`
     */
    public static function getGraphic(path:String, ?detailedPath:Bool = false){
        var p:String;

        if (!detailedPath)
            p = Path.normalize('${Msys.getModPath()}/$path');
        else
            p = Path.normalize(path);

        if (Path.extension(p) == "")
            p = '$p.png';

        if (!mod_assets.hasBitmapData(p))
            mod_assets.setBitmapData(p, BitmapData.fromFile(p));

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(mod_assets.getBitmapData(p), false, null, false);
        graphic.persist = true;
        return graphic;
    }

    /**
     * Searches in the root folder of the currently loaded mod.
     * @param path Example: `assets/songs/Test/Inst.ogg`
     * @param detailedPath If enabled, it will use the raw path instead of automatically fixing and finding the path.
     * @return `Sound`
     */
    public static function getSound(path:String, ?detailedPath:Bool = false){
        var p:String;

        if (!detailedPath)
            p = Path.normalize('${Msys.getModPath()}/$path');
        else
            p = Path.normalize(path);

        if (Path.extension(p) == "")
            p = '$p.ogg';

        if (!mod_assets.hasSound(p))
            mod_assets.setSound(p, Sound.fromFile(p));

        return mod_assets.getSound(p);
    }
    
    /**
     * Searches in the root folder of the currently loaded mod.
     * @param path Example: `assets/data/junk.txt`
     * @param detailedPath If enabled, it will use the raw path instead of automatically fixing and finding the path.
     * @return `String`
     */
    public static function getContent(path:String, ?detailedPath:Bool = false){
        var p:String;

        if (!detailedPath)
            p = Path.normalize('${Msys.getModPath()}/$path');
        else
            p = Path.normalize(path);

        if (Path.extension(p) == "")
            p = '$p.txt';

        return File.getContent(p);
    }

    /**
     * Searches in the root folder of the currently loaded mod.
     * @param path Example: `assets/data/charts/test/test.json`
     * @param detailedPath If enabled, it will use the raw path instead of automatically fixing and finding the path.
     * @return `JSON`
     */
    public static function getJSON(path:String, ?detailedPath:Bool = false){
        var p:String;

        if (!detailedPath)
            p = Path.normalize('${Msys.getModPath()}/$path');
        else
            p = Path.normalize(path);

        if (Path.extension(p) == "")
            p = '$p.json';

        return Json.parse(File.getContent(p));
    }

    /**
     * Searches in the root folder of the currently loaded mod.
     * @param path Example: `assets/data/Songlist.json`
     */
    public static function assetExists(path:String){
        var p:String = Path.normalize('${Msys.getModPath()}/$path');
        if (Path.extension(p) == "")
            p = '$p.json';

        return FileSystem.exists(p);
    }
}

/**
 * Both `name` and `iconPath` should be used in the Json file, `id` is reserved for in the engine as in reality that is the folder to the mod.
 */
typedef ModJson = {
    var name:String;
    var iconPath:String;
}

typedef ModData = {
    var mod:ModJson;
    var id:String;
    var songList:SongListJson;
}
#end