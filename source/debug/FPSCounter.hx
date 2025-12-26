package debug;

import sys.io.Process;
import sys.FileSystem;
import flixel.FlxG;
import openfl.text.TextField;
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import backend.ClientPrefs;
import openfl.system.System;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	public var ramUsage(get, never):Float;
	private var extensionRAM:String = '';
	private var extensionPC:String = '';

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
        defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 15, color, true);
        embedFonts = true;
		this.blendMode = BlendMode.ADD;
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 50) {
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout = 0.0;
	}

	inline function get_ramUsage():Float {
		#if windows
		return (cast(System.totalMemory, Float) / 1024 / 1024);
		#else
		return 0;
		#end
	}

	function onUpdate() {
		var username = Sys.environment()["USERNAME"];
		var os = Sys.systemName();

		if (ClientPrefs.data.detailedFPS) {
			extensionPC = 'User: $username' + ' | OS: $os';
			extensionRAM = ' | RAM: ${Math.floor(ramUsage)}MB';
		} else {
			extensionPC = '';
			extensionRAM = '';
		}
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		onUpdate();

		text = 'FPS: ${currentFPS}' + 
		' | Memory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}' 
		+ '${extensionRAM}'
		+ "\nCrazy Funker's 1.5 - Developer Build | [DO NOT DISTRIBUTE]"
		+ '\n${extensionPC}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
