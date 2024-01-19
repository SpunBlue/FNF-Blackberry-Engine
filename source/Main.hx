package;

import haxe.PosInfos;
import haxe.Log;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	private static final fps:Int =  #if (web || mobile) 60; #else 144; #end

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, InitState, fps, fps, true));

		#if (desktop || debug)
		addChild(new FPS(10, 10, 0xffffff));
		#end

		#if sys
		Log.trace = function(v:Dynamic, ?infos:PosInfos) {
			try{
				Sys.println('([${infos.fileName}]:${infos.className}:${infos.methodName}):${infos.lineNumber} :: $v');
			}
			catch(e:Dynamic){
				// do shit later
			}
		};
		#end
	}

	public static function createThread(f:Void -> Void){
        #if (target.threaded)
        sys.thread.Thread.create(() -> {
            f();
        });
        #else
        f();
        #end
    }
}