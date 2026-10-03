package states;

import csHxUtils.entities.CsMenu;
import csHxUtils.entities.SplitText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.GlobalState;

class MainMenuState extends FlxState
{
	var gameName:String = "Game";
	var globalState:GlobalState;

	override public function create()
	{
		super.create();
		globalState = new GlobalState();
		FlxG.plugins.addPlugin(globalState);

		FlxG.mouse.visible = true;

		var text = generateTitle();
		add(text);
		text.x = (FlxG.width - text.width) / 2;
		text.y = 96;

		var menu = new CsMenu(FlxG.width / 2, FlxG.height / 2, FlxTextAlign.CENTER, {
			keyboard: true,
			mouse: true,
			gamepad: true,
			gamepadId: 0
		});
		var mainPage = menu.createPage("Main");
		var settingsPage = menu.createPage("Settings");

		mainPage.addItem("Start Game", () ->
		{
			FlxG.switchState(() -> new PlayState());
		});

		mainPage.addItem("Settings", () ->
		{
			menu.openPage("Settings");
		});

		settingsPage.addItem("Back", () ->
		{
			menu.openPage("Main");
		});
		settingsPage.addItem("Toggle Fullscreen", () -> FlxG.fullscreen = !FlxG.fullscreen);

		mainPage.show(true);

		add(menu);

		globalState.createEmitter();
		add(globalState.emitter.activeMembers);
	}

	function generateText(text:String, targetColour:FlxColor, onClick:(text:SplitText) -> Void)
	{
		var text = new SplitText(0, 0, text);
		text.color = 0xff000000;
		text.borderColor = 0xffffffff;
		text.borderQuality = 4;
		text.borderSize = 4;
		text.borderStyle = OUTLINE;
		text.onMouseIn = () ->
		{
			text.animateWave(36, 0.075, 0.6, true);
			text.animateColour(targetColour, 0.075, 0.6);
		}
		text.onMouseOut = () ->
		{
			text.stopAnimation();
		}
		text.onClick = () ->
		{
			onClick(text);
		};

		return text;
	}

	function generateTitle()
	{
		var text = new SplitText(0, 0, gameName, SplitText.naiieveScaleDefaultOptions(2.5));
		text.color = 0xff000000;
		text.borderColor = 0xffffffff;
		text.borderQuality = 4;
		text.borderSize = 4;
		text.borderStyle = OUTLINE;
		text.animateWave(5, 0.1, 1.5, false);
		text.animateColourByArray([0xffa05080, 0xff80a050, 0xff5080a0], 0.075, 0.6,);

		return text;
	}
}
