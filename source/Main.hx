package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	private static var fps:Int = 144;

	public function new()
	{
		#if (web || mobile)
		fps = 60;
		#end

		super();
		addChild(new FlxGame(0, 0, FreeplayState, fps, fps, true));

		#if (desktop || debug)
		addChild(new FPS(10, 10, 0xffffff));
		#end
	}
}