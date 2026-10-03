package utils;

import csHxUtils.entities.CsEmitter;
import flixel.FlxBasic;
class GlobalState extends FlxBasic
{
	public var isUsingController:Bool = false;
	public var controllerId:Int = 0;
	public var emitter:CsEmitter;

	public function new()
	{
		super();
		emitter = new CsEmitter();
	}

	public function createEmitter()
	{
		emitter = new CsEmitter();
	}

}
