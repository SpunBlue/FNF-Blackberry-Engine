package;

import haxe.io.Path;
import openfl.Assets;
import flixel.FlxSprite;

#if CAN_MOD
import engine.modlib.ModdingSystem;
import sys.FileSystem;
#end

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	var icon:String = '';
	var isPlayer:Bool = false;

	public function new(newIcon:String, isPlayer:Bool = false, ?modID:String = "")
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(newIcon, modID);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(newIcon:String, ?modID:String = ""):Void
	{
		if (newIcon != icon)
		{
			#if CAN_MOD
			if (ModdingSystem.validMods.exists(modID)){
				var p:String = '${ModdingSystem.getModPathFromID(modID)}/$newIcon';

				if (FileSystem.exists(p))
					loadGraphic(ModAssets.getGraphic(p, true), true, 150, 150);
			}
			else if (ModdingSystem.curMod != null){
				if (ModAssets.assetExists(newIcon))
					loadGraphic(ModAssets.getGraphic(newIcon), true, 150, 150);
			}
			else
				loadGraphic(Paths.image('icons/icon-$newIcon'), true, 150, 150);
			#else
			loadGraphic(Paths.image('icons/icon-$newIcon'), true, 150, 150);
			#end

			// Doing it like this because I want to one day make it so you can select a mod to override default assets and this was
			// the most straight forward way to do what I wanted

			if (graphic == null)
				loadGraphic(Paths.image('icons/icon-$newIcon'), true, 150, 150);

			if (graphic == null)
				loadGraphic(Paths.image('icons/icon-face'), true, 150, 150);

			animation.add('icon', [0, 1], 0, false, isPlayer);
			animation.play('icon');
			icon = newIcon;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
