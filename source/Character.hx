package;

import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.display.BitmapData;
import openfl.Assets;
import Section.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
#if CAN_MOD
import haxe.io.Path;
import engine.modlib.ModdingSystem;
#end

using StringTools;

class CharacterUtil{
	/**
	 * All characters that come with the Engine, done like this since I don't think it's possible to search through the character directory in HTML5
	 */
	public static final characterList:Array<String> = [
		'bf',
		'gf',
		'dad'
	];

	/**
	 * `Character Name`, `CharacterJson`
	 */
	public static var characters:Map<String, CharacterJson> = new Map<String, CharacterJson>();

	/**
	 * Loads all hardcoded Characters
	 */
	public static function loadCharacters(){
		trace('Loading Hardcoded Characters');

		for (char in CharacterUtil.characterList){
			var data:CharacterJson = Json.parse(Assets.getText(Paths.json('characters/$char')));
			
			CharacterUtil.characters.set(char, data);
			trace('Loaded $char (Hardcoded)');
		}
	}

	public static function getCharacter(character:String):Array<Any>{		
		if (ModdingSystem.curMod != null && FileSystem.exists(Path.normalize('${ModdingSystem.getModPath()}/assets/data/characters/$character.json')))
			return [ModAssets.getJSON('assets/data/characters/$character.json'), true];
		
		if (characters.exists(character))
			return [characters.get(character), false];
		else{
			trace('Failed to find character: $character');
			return null;
		}
	}
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];

	public var data:CharacterJson = null;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		var stuff = CharacterUtil.getCharacter(character);

		data = stuff[0];
		var isMod:Bool = stuff[1];

		if (isMod == false)
			frames = FlxAtlasFrames.fromSparrow(Paths.image(data.imagePath.split('.')[0]), Assets.getText(Paths.file('images/${data.xmlPath}')));
		else{
			#if CAN_MOD
			/*var imagesPath:String = Path.normalize('${ModdingSystem.getModPath()}/assets/images');

			frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile('$imagesPath/${data.imagePath}'), File.getContent('$imagesPath/${data.xmlPath}'));*/

			frames = FlxAtlasFrames.fromSparrow(ModAssets.getGraphic('assets/images/${data.imagePath}'), ModAssets.getContent('assets/images/${data.xmlPath}'));
			#else
			trace('FAILURE WITH MODDING SYSTEM - Attempted to load non-existent data from Character.hx');
			#end
		}

		for (anim in data.animations){
			if (anim.frames != null && anim.frames.length > 0)
				animation.addByIndices(anim.name, anim.prefix, anim.frames, "", anim.fps, anim.loop);
			else
				animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);

			if (anim.offsets != null)
				addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
		}

		if (data.flipX != null)
			flipX = data.flipX;

		if (data.graphicSize != null)
			setGraphicSize(graphic.width * data.graphicSize);

		if (data.positionOffsets != null)
			setPosition(x + data.positionOffsets[0], y + data.positionOffsets[1]);

		dance();
		animation.finish();

		if (isPlayer)
			flipX = !flipX;
	}

	function quickAnimAdd(name:String, prefix:String)
	{
		animation.addByPrefix(name, prefix, 24, false);
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (animation.exists('danceRight') && animation.exists('danceLeft')){
			danced = !danced;

			if (danced)
				playAnim('danceRight');
			else
				playAnim('danceLeft');
		}
		else
			playAnim('idle');
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef CharacterJson = {
	var imagePath:String;
	var xmlPath:String;
    var animations:Array<AnimationData>;
	var ?positionOffsets:Array<Float>;
	var ?cameraOffsets:Array<Float>;
	var ?iconPath:String; // Defaults to face
	var ?flipX:Bool;
	var ?graphicSize:Float;
}

typedef AnimationData = {
	var name:String;
	var prefix:String;
	var ?frames:Array<Int>;
	var fps:Int;
	var loop:Bool;
	var ?offsets:Array<Int>; // [1, 1] X & Y
}