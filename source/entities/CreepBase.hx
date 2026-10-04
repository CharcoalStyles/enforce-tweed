package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.path.FlxBasePath.FlxTypedBasePath;
import flixel.path.FlxPath;
import flixel.util.FlxSignal.FlxTypedSignal;

class CreepBase extends FlxSprite
{
	public var onEndReached(default, null) = new FlxTypedSignal<() -> Void>();

	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic("assets/images/enemies/skeleton/Run-Sheet.png", true, 64, 64);

		// set origin to centre bottom
		offset.set(0, height / 2);

		this.animation.add("run", [0, 1, 2, 3, 4, 5], 12);
		this.animation.play("run");
		facing = RIGHT;
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
	}

	public function setPath(pathIn:FlxPath)
	{
		this.path = new FlxPath(pathIn.nodes);
		facing = pathIn.head().x > pathIn.nodes[1].x ? LEFT : RIGHT;
		this.path.onNodeReached.add((listener:FlxTypedBasePath<FlxObject>) ->
		{
			if (listener.next.equals(pathIn.tail()))
			{
				onEndReached.dispatch();
				return;
			}
			facing = listener.current.x > listener.next.x ? LEFT : RIGHT;
		});
	}
}
