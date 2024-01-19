package;

import engine.SongDefs.SongListJson;
import flixel.math.FlxRect;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import haxe.io.Path;
import openfl.Assets;
import haxe.Json;
import Character.CharacterUtil;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxG;
import flixel.FlxState;
#if CAN_MOD
import engine.modlib.ModdingSystem;
import Character.CharacterJson;
#end

class InitState extends FlxState{
    var loadingComplete:Bool = false;

    var amt2Search:Int = 0;
    var curProgress:Int = 0;

    var progressText:FlxText;

    override function create(){
        #if CAN_MOD
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(202, 255, 77));
        add(bg);

        var funkers:FlxSprite = new FlxSprite();
        funkers.loadGraphic(Paths.image('loadingFunkers'));
        funkers.setGraphicSize(funkers.graphic.width * 0.7);
        funkers.updateHitbox();
        funkers.screenCenter();
        add(funkers);
   
        progressText = new FlxText(0, FlxG.height - 256, FlxG.width, 'Processing...', 16);
        progressText.setFormat(null, 64, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        progressText.borderSize = 4;
        add(progressText);
        #else
        var funkay:FlxSprite = new FlxSprite();
		funkay.loadGraphic(Paths.image('funkay'));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		add(funkay);
        #end

        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
        new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
        {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        FlxG.save.bind('funkin-blackberry', 'spunblue');
		Highscore.load();

        super.create();

        CharacterUtil.loadCharacters();

        #if CAN_MOD
        Main.createThread(function(){
            ModAssets.mod_assets.clear();

            var rootDir = ModdingSystem.getRootPath();
            trace('Root Dir: $rootDir');
    
            var mods:Array<String> = FileSystem.readDirectory(rootDir);
    
            amt2Search = mods.length;
            curProgress = 0;
    
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
                    ++curProgress;
                }
                else
                    amt2Search -= 1;
            }

            loadingComplete = true;
        });
        #else
        loadingComplete = true;
        #end
    }

    override function update(elapsed:Float){
        #if CAN_MOD
        if (amt2Search != 0)
            progressText.text = '$curProgress/$amt2Search';
        #end

        super.update(elapsed);

        if (loadingComplete)
            FlxG.switchState(new FreeplayState());
    }
}