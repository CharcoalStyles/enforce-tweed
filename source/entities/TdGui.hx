package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxSignal.FlxTypedSignal;

class TdGui extends FlxTypedGroup<FlxSprite>
{
	public var onNextWave:FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();

	public function new()
	{
		super();

		var sprite = new FlxSprite(0, FlxG.height - 32);
		sprite.makeGraphic(FlxG.width, 32, 0xff404040);
		add(sprite);

		var nextWaveButton = new FlxButton(0, 0, "Next Wave", () -> onNextWave.dispatch());
		nextWaveButton.y = FlxG.height - nextWaveButton.height - 8;
		add(nextWaveButton);
	}
}
