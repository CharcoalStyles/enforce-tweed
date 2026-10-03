package states;

import flixel.FlxG;
import flixel.FlxState;
import states.subStates.PauseState;
import utils.GlobalState;

class PlayState extends FlxState
{
	var globalState:GlobalState;

	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		FlxG.camera.antialiasing = true;

		globalState = FlxG.plugins.get(GlobalState);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			this.subState = new PauseState(globalState.controllerId);
			this.subState.create();
			this.subState.closeCallback = () ->
			{
				this.subState = null;
			}
		}
	}
}
